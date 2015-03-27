//
//  RCSettingsCustomVC.h
//  RaceControl
//
//  Created by Vitaliy on 25.03.15.
//  Copyright (c) 2015 Technologies33. All rights reserved.

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <FacebookSDK/FacebookSDK.h>
#import "RCHomeViewController.h"

@interface RCSettingsCustomVC : UIViewController <MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate, UITextFieldDelegate>

@property(nonatomic,retain) RCHomeViewController *homeViewController;
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

- (IBAction)logoutBtnPressed:(id)sender;

@end
