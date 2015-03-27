//
//  RCAlertView.h
//  RaceControl
//
//  Created by Vitaliy on 27.03.15.
//  Copyright (c) 2015 Technologies33. All rights reserved.

typedef void(^RCAlertViewBlock)(NSInteger clickedButtonIndex, NSString* promptString);

@interface RCAlertView : NSObject

+ (void)showWithTitle:(NSString*)title andText:(NSString*)text andFirstButtonTitle:(NSString*)firstTitle andSecondButtonTitle:(NSString*)secondTitle andPrompt:(NSString*)prompt andCompletionHandler:(RCAlertViewBlock)handler;

+ (void)showWithTitle:(NSString*)title andText:(NSString*)text;

@end
