//
//  RCLocationManager.m
//  RaceControl
//
//  Created by Vitaliy on 27.03.15.
//  Copyright (c) 2015 Technologies33. All rights reserved.
//

#import "RCLocationManager.h"

@implementation RCLocationManager

+ (RCLocationManager*)sharedInstance {
    __strong static RCLocationManager* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}


- (id)init {
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.delegate = self;
        _locationType = LocationManagerTypeNone;
    }
    
    return self;
}


#pragma mark -  CLLocationManager delagate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    _lastLocation = location;
    _lastCoordinate = location.coordinate;
    [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_DID_CHANGED_NOTIFICATION object:location userInfo:@{@"location":location}];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_DID_FAILED_NOTIFICATION object:error userInfo:@{@"error":error}];
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined && [_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_AUTHORIZATION_STATUS_CHANGED_NOTIFICATION object:self userInfo:@{@"status":@(status)}];
}


#pragma mark -

- (void)start {
    [_locationManager startUpdatingLocation];
    if (_locationType == LocationManagerTypeNone) {
        _locationType = LocationManagerTypeStandart;
    } else if (_locationType == LocationManagerTypeSignificant) {
        _locationType = LocationManagerTypeSignificant | LocationManagerTypeStandart;
    }
}


- (void)stop {
    [_locationManager stopUpdatingLocation];
    if (_locationType & LocationManagerTypeSignificant) {
        _locationType = LocationManagerTypeSignificant;
    } else
        _locationType = LocationManagerTypeNone;
}


- (void)startSignificant {
    [_locationManager startMonitoringSignificantLocationChanges];
    if (_locationType == LocationManagerTypeNone) {
        _locationType = LocationManagerTypeSignificant;
    } else if (_locationType == LocationManagerTypeStandart)
        _locationType = LocationManagerTypeStandart | LocationManagerTypeSignificant;
}


- (void)stopSignificant {
    [_locationManager stopMonitoringSignificantLocationChanges];
    if (_locationType & LocationManagerTypeStandart) {
        _locationType = LocationManagerTypeStandart;
    } else
        _locationType = LocationManagerTypeNone;
}



@end
