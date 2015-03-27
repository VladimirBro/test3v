//
//  RCLocationManager.h
//  RaceControl
//
//  Created by Vitaliy on 27.03.15.
//  Copyright (c) 2015 Technologies33. All rights reserved.

@import Foundation;
@import MapKit;

#define LOCATION_DID_CHANGED_NOTIFICATION @"locationDidChangeNotification"
#define LOCATION_DID_FAILED_NOTIFICATION @"locationDidFailedNotification"
#define LOCATION_AUTHORIZATION_STATUS_CHANGED_NOTIFICATION @"locationAuthorizationStatusChangedNotification"

typedef enum {
    LocationManagerTypeNone = 0x00,
    LocationManagerTypeStandart = 0x10,
    LocationManagerTypeSignificant = 0x01,
    LocationManagetTypeStandartAndSignificant = 0x11
} RCLocationManagerType;

@interface RCLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic) RCLocationManagerType locationType;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation* lastLocation;
@property (nonatomic) CLLocationCoordinate2D lastCoordinate;

+ (RCLocationManager*)sharedInstance;
- (void)start;
- (void)stop;
- (void)startSignificant;
- (void)stopSignificant;

@end
