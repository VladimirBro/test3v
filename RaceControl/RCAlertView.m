//
//  RCAlertView.m
//  RaceControl
//
//  Created by Vitaliy on 27.03.15.
//  Copyright (c) 2015 Technologies33. All rights reserved.

#import "RCAlertView.h"

@interface RCAlertView ()

@property (nonatomic, weak) UIAlertView* alertViewInstance;
@property (nonatomic, strong) id selfRef;
@property (nonatomic, copy) RCAlertViewBlock block;

@end


@implementation RCAlertView

+ (void) showWithTitle:(NSString*)title andText:(NSString*)text andFirstButtonTitle:(NSString*)firstTitle andSecondButtonTitle:(NSString*)secondTitle andPrompt:(NSString*)prompt andCompletionHandler:(RCAlertViewBlock)handler {
    
    RCAlertView* a = [[RCAlertView alloc] init];
    a.selfRef = a;
    a.block = handler;
    
    UIAlertView* av = [[UIAlertView alloc] init];
    av.title = title;
    av.message = text;
    av.delegate = a;
    if (firstTitle) {
        [av addButtonWithTitle:firstTitle];
    }
    if (secondTitle) {
        [av addButtonWithTitle:secondTitle];
    }
    if (prompt) {
        av.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *textfield = [av textFieldAtIndex: 0];
        textfield.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }
    a.alertViewInstance = av;
    [av show];
}


+ (void)showWithTitle:(NSString*)title andText:(NSString*)text {
    [RCAlertView showWithTitle:title andText:text andFirstButtonTitle:@"OK" andSecondButtonTitle:nil andPrompt:nil andCompletionHandler:^(NSInteger clickedButtonIndex, NSString *promptString) {
    }];
}


- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    UITextField *textfield = nil;
    if (self.alertViewInstance.alertViewStyle == UIAlertViewStylePlainTextInput) {
        textfield = [alertView textFieldAtIndex: 0];
    }
    NSString* prompt = textfield.text;
    if (alertView.numberOfButtons <= 1) {
        self.block(buttonIndex, prompt);
    } else {
        self.block(buttonIndex, prompt);
    }
    self.selfRef = nil;
}




@end
