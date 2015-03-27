//
//  RCDraw2D.m
//  RaceControl
//
//  Created by Vitaliy on 25.03.15.
//  Copyright (c) 2015 Technologies33. All rights reserved.
//

#import "RCDraw2D.h"

@implementation RCDraw2D

- (void)drawRect:(CGRect)rect {
    int w = 48;
    for (int i = 0; i < 2; i++) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetLineWidth(context, .4);
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = {0.0, 4.0, 2.0, 1.0};
        CGColorRef color = CGColorCreate(colorspace, components);
        CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
        CGContextMoveToPoint(context, 0, w);
        CGContextAddLineToPoint(context, 320, w);
        CGContextStrokePath(context);
        CGColorSpaceRelease(colorspace);
        CGColorRelease(color);
        w += 48;
    }
}

@end
