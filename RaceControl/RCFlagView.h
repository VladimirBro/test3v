//
//  RCFlagView.h
//  RaceControl
//
//  Created by Jack on 4/12/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCFlagView : UIImageView
{
    UILabel *number;
    UIColor *color;
    NSString *type;
}

@property (nonatomic, strong) UILabel *number;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSString *type;
@end
