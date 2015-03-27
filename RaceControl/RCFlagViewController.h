//
//  RCFlagViewController.h
//  RaceControl
//
//  Created by Jack on 4/8/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "RCAppDelegate.h"
#import "UIColor+String.h"
#import "RCFlagView.h"

@class RCHomeViewController;

@interface RCFlagViewController : UIViewController
{
    IBOutlet UILabel *lblMessage;
    IBOutlet UIView *flagsView;
    IBOutlet UIImageView *noFlags;
    ASIFormDataRequest *fetchTrackRequest;
    ASIFormDataRequest *fetchEventRequest;
    ASIFormDataRequest *logoutRequest;
    ASIFormDataRequest *acknowledgeRequest;
    ASIFormDataRequest *trackrequest;
    NSString *trackName;
    NSString *trackId;
    NSString *eventId;
    RCAppDelegate *appDelegate;
    RCFlagView *safetyFlagView;
    NSDictionary *currentFlags;
    BOOL isFlashing;
    BOOL isWaving;
}

@property(nonatomic,retain) NSString *trackId;
@property(nonatomic,retain) NSString *eventId;
@property(nonatomic,retain) NSDictionary *currentFlags;
@property(nonatomic,retain) RCHomeViewController *homeViewController;

-(void)sendTracking:(NSTimer *)timer;

@end
