//
//  RCSettingsViewController.h
//  RaceControl
//
//  Created by Technologies33 on 07/08/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ASIFormDataRequest.h"
#import "RCHomeViewController.h"
#import "RCCarTableViewController.h"

@interface RCSettingsViewController : UIViewController<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, FBWebDialogsDelegate>

@property(nonatomic,retain) RCHomeViewController *homeViewController;
@property(nonatomic,retain) IBOutlet UILabel *lblCarNo;
@property(nonatomic,retain) IBOutlet UILabel *lblEmail;
@property(nonatomic,retain) IBOutlet UIButton *logoutBtn;
@end
