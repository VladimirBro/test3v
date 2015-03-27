//
//  RCMotionDetector.m
//  RaceControl
//
//  Created by Vitaliy on 27.03.15.
//  Copyright (c) 2015 Technologies33. All rights reserved.

#import "RCMotionDetector.h"

CGFloat kMinimumSpeed        = 0.3f;
CGFloat kMaximumWalkingSpeed = 1.9f;
CGFloat kMaximumRunningSpeed = 7.5f;
CGFloat kMinimumRunningAcceleration = 3.5f;

@interface RCMotionDetector ()

@property (strong, nonatomic) NSTimer *shakeDetectingTimer;
@property (nonatomic) RCMotionType previousMotionType;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CMMotionManager *motionManager;
@property (strong, nonatomic) CMMotionActivityManager *motionActivityManager;

@end


@implementation RCMotionDetector

+ (RCMotionDetector *)sharedInstance
{
    static RCMotionDetector *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


+ (BOOL)motionHardwareAvailable {
    static BOOL isAvailable = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isAvailable = [CMMotionActivityManager isActivityAvailable];
    });
    return isAvailable;
}


- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLocationChangedNotification:) name:LOCATION_DID_CHANGED_NOTIFICATION object:nil];
        self.motionManager = [[CMMotionManager alloc] init];
    }
    
    return self;
}


- (void)startDetection
{
    [[RCLocationManager sharedInstance] start];
    
    _shakeDetectingTimer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(detectShaking) userInfo:Nil repeats:YES];
    
    [_motionManager startAccelerometerUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        _acceleration = accelerometerData.acceleration;
        [self calculateMotionType];
        dispatch_async(dispatch_get_main_queue(), ^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            if (self.delegate && [self.delegate respondsToSelector:@selector(motionDetector:accelerationChanged:)]) {
                [self.delegate motionDetector:self accelerationChanged:_acceleration];
            }
#pragma GCC diagnostic pop
            if (_accelerationChangedBlock) {
                _accelerationChangedBlock (_acceleration);
            }
        });
    }];
    
    if (_useM7IfAvailable && [RCMotionDetector motionHardwareAvailable]) {
        if (!_motionActivityManager) {
            _motionActivityManager = [[CMMotionActivityManager alloc] init];
        }
        
        [_motionActivityManager startActivityUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMMotionActivity *activity) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (activity.walking) {
                    _motionType = MotionTypeWalking;
                } else if (activity.running) {
                    _motionType = MotionTypeRunning;
                } else if (activity.automotive) {
                    _motionType = MotionTypeAutomotive;
                } else if (activity.stationary || activity.unknown) {
                    _motionType = MotionTypeNotMoving;
                }
                
                if (_motionType != _previousMotionType) {
                    _previousMotionType = _motionType;
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
                    if (self.delegate && [self.delegate respondsToSelector:@selector(motionDetector:motionTypeChanged:)]) {
                        [self.delegate motionDetector:self motionTypeChanged:_motionType];
                    }
#pragma GCC diagnostic pop
                    if (_motionTypeChangedBlock) {
                        _motionTypeChangedBlock (_motionType);
                    }
                }
            });
        }];
    }
}


- (void)stopDetection {
    [_shakeDetectingTimer invalidate];
    _shakeDetectingTimer = nil;
    
    [[RCLocationManager sharedInstance] stop];
    [_motionManager stopAccelerometerUpdates];
    [_motionActivityManager stopActivityUpdates];
}


#pragma mark -
- (void)setMinimumSpeed:(CGFloat)speed {
    kMinimumSpeed = speed;
}

- (void)setMaximumWalkingSpeed:(CGFloat)speed {
    kMaximumWalkingSpeed = speed;
}

- (void)setMaximumRunningSpeed:(CGFloat)speed {
    kMaximumRunningSpeed = speed;
}

- (void)setMinimumRunningAcceleration:(CGFloat)acceleration {
    kMinimumRunningAcceleration = acceleration;
}
#pragma mark -


- (void)calculateMotionType {
    if (_useM7IfAvailable && [RCMotionDetector motionHardwareAvailable]) {
        return;
    }
    
    if (_currentSpeed < kMinimumSpeed) {
        _motionType = MotionTypeNotMoving;
    } else if (_currentSpeed <= kMaximumWalkingSpeed) {
        _motionType = _isShaking ? MotionTypeRunning : MotionTypeWalking;
    } else if (_currentSpeed <= kMaximumRunningSpeed) {
        _motionType = _isShaking ? MotionTypeRunning : MotionTypeAutomotive;
    } else {
        _motionType = MotionTypeAutomotive;
    }
    
    if (self.motionType != self.previousMotionType) {
        self.previousMotionType = self.motionType;
        dispatch_async(dispatch_get_main_queue(), ^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            if (self.delegate && [self.delegate respondsToSelector:@selector(motionDetector:motionTypeChanged:)]) {
                [self.delegate motionDetector:self motionTypeChanged:_motionType];
            }
#pragma GCC diagnostic pop
            if (_motionTypeChangedBlock) {
                _motionTypeChangedBlock (_motionType);
            }
        });
    }
}


- (void)detectShaking {
    static NSMutableArray *shakeDataForOneSec = nil;
    static float currentFiringTimeInterval = 0.0f;
    
    currentFiringTimeInterval += 0.01f;
    if (currentFiringTimeInterval < 1.0f) {
        if (!shakeDataForOneSec)
            shakeDataForOneSec = [NSMutableArray array];
        NSValue *boxedAcceleration = [NSValue value:&_acceleration withObjCType:@encode(CMAcceleration)];
        [shakeDataForOneSec addObject:boxedAcceleration];
    } else {
        int shakeCount = 0;
        for (NSValue *boxedAcceleration in shakeDataForOneSec) {
            CMAcceleration acceleration;
            [boxedAcceleration getValue:&acceleration];
            
            double accX_2 = powf(acceleration.x,2);
            double accY_2 = powf(acceleration.y,2);
            double accZ_2 = powf(acceleration.z,2);
            
            double vectorSum = sqrt(accX_2 + accY_2 + accZ_2);
            
            if (vectorSum >= kMinimumRunningAcceleration) {
                shakeCount++;
            }
        }
        _isShaking = shakeCount > 0;
        
        shakeDataForOneSec = nil;
        currentFiringTimeInterval = 0.0f;
    }
}


#pragma mark - handler locationManager notification
- (void)handleLocationChangedNotification:(NSNotification*)note {
    _currentLocation = [RCLocationManager sharedInstance].lastLocation;
    _currentSpeed = _currentLocation.speed;
    if (_currentSpeed < 0) {
        _currentSpeed = 0;
    }
    dispatch_async(dispatch_get_main_queue(),^{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        if (self.delegate && [self.delegate respondsToSelector:@selector(motionDetector:locationChanged:)]) {
            [self.delegate motionDetector:self   locationChanged:_currentLocation];
        }
#pragma GCC diagnostic pop
        if (_locationChangedBlock) {
            _locationChangedBlock (_currentLocation);
        }
    });
    [self calculateMotionType];
}


@end
