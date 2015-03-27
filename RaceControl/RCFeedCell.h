//
//  RCFeedCell.h
//  RaceControl
//
//  Created by Sabir on 5/2/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCFeedCell : UITableViewCell

// IBOutlets connected to controls to prototype cells in StoryBoard
@property (nonatomic, strong) IBOutlet UILabel *lblFeed;
@property (nonatomic, strong) IBOutlet UILabel *lblTime;
@property (nonatomic, strong) IBOutlet UIImageView *imgSymbol;

// Set data on cell
-(void)setData : (NSDictionary*)feed;

@end
