//
//  RCAppDelegate.h
//  RaceControl
//
//  Created by Jack on 4/8/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <CoreLocation/CoreLocation.h>
#import <FacebookSDK/FacebookSDK.h>
@import CoreLocation;

@interface RCAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate, PNDelegate>


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSMutableDictionary *userDictionary;
///pubnub client
@property (nonatomic, strong) PNConfiguration *pubnubConfig;
@property (nonatomic, strong) CLLocationManager *locationMgr;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) BOOL isLocationFetched;
@property (nonatomic, assign) BOOL isConnectionLost;
//
@property (nonatomic, assign) BOOL purchaseInitiated;
// spotter purchase flag
@property (nonatomic, assign) BOOL isPro;
// spotter consumed flag
@property (nonatomic, assign) BOOL isConsumed;

-(void)initPubnub;
-(void) subscribeToChannel:(NSString *)channel;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;

@end
