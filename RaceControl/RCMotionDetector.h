//
//  RCMotionDetector.h
//  RaceControl
//
//  Created by Vitaliy on 27.03.15.
//  Copyright (c) 2015 Technologies33. All rights reserved.

#import "RCLocationManager.h"
@import Foundation;
@import CoreMotion;

@class RCMotionDetector;
typedef enum {
    MotionTypeNotMoving = 1,
    MotionTypeWalking,
    MotionTypeRunning,
    MotionTypeAutomotive
} RCMotionType;


@protocol RCMotionDetectorDelegate <NSObject>

@optional
- (void)motionDetector:(RCMotionDetector*)motionDetector motionTypeChanged:(RCMotionType)motionType;
- (void)motionDetector:(RCMotionDetector*)motionDetector locationChanged:(CLLocation*)location;
- (void)motionDetector:(RCMotionDetector*)motionDetector accelerationChanged:(CMAcceleration)acceleration;

@end


@interface RCMotionDetector : NSObject

@property (weak, nonatomic) id<RCMotionDetectorDelegate> delegate DEPRECATED_MSG_ATTRIBUTE(" Use blocks instead");

@property (copy) void (^motionTypeChangedBlock) (RCMotionType motionType);
@property (copy) void (^locationChangedBlock) (CLLocation *location);
@property (copy) void (^accelerationChangedBlock) (CMAcceleration acceleration);

@property (nonatomic, readonly) RCMotionType motionType;
@property (nonatomic, readonly) double currentSpeed;
@property (nonatomic, readonly) CMAcceleration acceleration;
@property (nonatomic, readonly) BOOL isShaking;
@property (nonatomic) BOOL useM7IfAvailable NS_AVAILABLE_IOS(7_0);

+ (RCMotionDetector*)sharedInstance;
- (void)startDetection;
- (void)stopDetection;

- (void)setMinimumSpeed:(CGFloat)speed;
- (void)setMaximumWalkingSpeed:(CGFloat)speed;
- (void)setMaximumRunningSpeed:(CGFloat)speed;
- (void)setMinimumRunningAcceleration:(CGFloat)acceleration;

@end
