//
//  RCFlagView.m
//  RaceControl
//
//  Created by Jack on 4/12/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import "RCFlagView.h"

@implementation RCFlagView
@synthesize number, color, type;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
       
        self.autoresizesSubviews = YES;
        number = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        number.textAlignment = NSTextAlignmentCenter;
        number.font = [UIFont boldSystemFontOfSize:50.0];
        [self addSubview:number];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
