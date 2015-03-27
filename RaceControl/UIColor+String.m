//
//  UIColor+HexString.m
//  AgentArtemis
//
//  Created by Harsh Vardhan Jaiswal on 23/01/12.
//  Copyright 2012 Medma Informatix Pvt Ltd. All rights reserved.
//

#import "UIColor+String.h"

@interface UIColor()


@end


@implementation UIColor_String

+ (UIColor *) colorWithString: (NSString *) string {
    NSString *colorString = [string uppercaseString];
    UIColor *color;
    if ([colorString isEqualToString:@"RED"]) {
        color = [UIColor redColor];
    }
    else if ([colorString isEqualToString:@"YELLOW"]) {
        color = [UIColor colorWithRed:234.0f/255.0f green:239.0f/255.0f blue:24.0f/255.0f alpha:1.0];
    }
    else if ([colorString isEqualToString:@"GREEN"]) {
        color = [UIColor greenColor];
    }
    else if ([colorString isEqualToString:@"BLUE"]) {
        color = [UIColor blueColor];
    }
    else if ([colorString isEqualToString:@"BLACK"]) {
        color = FLAG_BLACK_COLOR;
    }
    else if ([colorString isEqualToString:@"WHITE"]) {
        color = [UIColor whiteColor];
    }
    else if ([colorString isEqualToString:@"RESTART"]) {
        color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"restart_flag.png"]];
    }
    else if ([colorString isEqualToString:@"FINISH"]) {
        color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"finish_flag.png"]];
    }
    else if ([colorString isEqualToString:@"SAFETY"]) {
        color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"safety_flag.png"]];
    }
    else {
        color = [UIColor whiteColor];
    }
    return color;
}


@end 