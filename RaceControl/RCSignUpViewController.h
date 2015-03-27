//
//  RCSignUpViewController.h
//  RaceControl
//
//  Created by Jack on 4/8/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "RCCarTableViewController.h"

@interface RCSignUpViewController : UIViewController <UITextFieldDelegate>
{
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtUserName;
    IBOutlet UITextField *txtPassword;
    IBOutlet UITextField *txtConfirmPassword;
    IBOutlet UIScrollView *scrollView;
    UITextField *activeField;
    
    IBOutlet UIButton *registerBtn;
    NSMutableDictionary *userData;
}

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)registerAction:(id)sender;

@end
