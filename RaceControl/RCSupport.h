//
//  RCSupport.h
//  RaceControl
//
//  Created by Jack on 4/8/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

BOOL                internetActive;
Reachability        *internetReachable;

@interface RCSupport : NSObject
{

}

@property (nonatomic,strong) Reachability   *internetReachable;
@property (nonatomic,assign) BOOL           *internetActive;

+(void)initializeRegistration;

+(void)checkNetworkStatus:(NSNotification *)notice;

+(void)unRegistration;

+(BOOL)getNetworkStatus;

+(BOOL)isNetworkAvaialble;

+(void)showAlert:(NSString *)message;

+ (NSString*)getUUID;

/*** To return height of text acoording to width and font passed ***/
+ (float)returnHeightOfText:(NSString *)text width:(float)frameWidth font:(UIFont *)font;

// calculating time interval
+ (NSString *) checkTimeIntervalWithStartDate:(NSTimeInterval)interval;

@end
