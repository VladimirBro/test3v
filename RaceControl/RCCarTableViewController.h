//
//  RCCarViewController.h
//  RaceControl
//
//  Created by Technologies33 on 07/08/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "RCAppDelegate.h"
#import "RCFlagViewController.h"

@class RCHomeViewController;


@interface RCCarTableViewController : UITableViewController
{
    NSMutableDictionary *userData;
    IBOutlet UITextField *txtCarNo;
    
    IBOutlet UITextField *txtCarClass;
    IBOutlet UITextField *txtTransponderNumber;
    IBOutlet UIButton *btnDone;
    BOOL isFromSettings;
}

@property(nonatomic,retain) NSMutableDictionary *userData;
@property(assign) BOOL isFromSettings;
@property(nonatomic,retain) RCHomeViewController *homeViewController;

@end
