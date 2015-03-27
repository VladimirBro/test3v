//
//  RCFacebookSignUpViewController.h
//  RaceControl
//
//  Created by Developer on 16/05/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "RCCarTableViewController.h"

@interface RCFacebookSignUpViewController : UIViewController<UITextFieldDelegate>
{
    NSMutableDictionary *userData;
}
@property (nonatomic, strong) id <FBGraphUser> fbUserData;

@end
