//
//  RCSplashViewController.h
//  RaceControl
//
//  Created by Sabir on 5/7/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "JSON.h"

@interface RCSplashViewController : UIViewController<FBLoginViewDelegate>
{
    IBOutlet UIImageView *splashImage;
    IBOutlet UIButton *loginBtn;
    IBOutlet UIButton *registerBtn;
    BOOL isLoaded;
}

@end
