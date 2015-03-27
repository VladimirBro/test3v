//
//  RCFeedCell.m
//  RaceControl
//
//  Created by Sabir on 5/2/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import "RCFeedCell.h"

@implementation RCFeedCell
@synthesize lblFeed,lblTime, imgSymbol;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// Set data on cell
-(void)setData : (NSDictionary*)feed
{
    self.lblFeed.text = [feed valueForKey:@"feed"];
    float textHeight = [RCSupport returnHeightOfText:[feed valueForKey:@"feed"] width:245.0f font:[UIFont systemFontOfSize:15.0f]];
    //NSLog(@"setData->textHeight : %f",textHeight);
    CGRect frame = self.lblFeed.frame;
    frame.size.height = textHeight;
    lblFeed.frame = frame;
    self.lblTime.text = [RCSupport checkTimeIntervalWithStartDate:[[feed valueForKey:@"time"] doubleValue]];
    //self.imgSymbol.image = [UIImage imageNamed:@"user_symbol.png"];
}

@end
