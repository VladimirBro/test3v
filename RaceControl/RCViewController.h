//
//  RCViewController.h
//  RaceControl
//
//  Created by Jack on 4/8/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ASIFormDataRequest.h"
#import "JSON.h"

@interface RCViewController : UIViewController<UITextFieldDelegate, FBLoginViewDelegate>
{
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPassword;
    IBOutlet UIScrollView *scrollView;
    UITextField *activeField;
    
    IBOutlet UIImageView *splashImageView;
    
    IBOutlet UIButton *loginBtn;
    IBOutlet UIButton *registerBtn;
}

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)loginAction:(id)sender;


@end
