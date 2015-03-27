//
//  RCSettingsVC.h
//  RaceControl
//
//  Created by Vitaliy on 24.03.15.
//  Copyright (c) 2015 Technologies33. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCHomeViewController.h"

@import MessageUI;

@interface RCSettingsVC : UIViewController <UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UITextFieldDelegate>
{
    
    IBOutlet UITableView *myTableView;
    NSMutableArray *nameRows;
}

@property(nonatomic,retain) RCHomeViewController *homeViewController;


@end
