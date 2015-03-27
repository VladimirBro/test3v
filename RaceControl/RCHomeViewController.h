//
//  RCHomeViewController.h
//  RaceControl
//
//  Created by Sabir on 4/26/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "RCAppDelegate.h"
#import "RCFlagViewController.h"
#import "RCFeedCell.h"
#import "IAPHelper.h"
#import "IAPSupport.h"
#import <FacebookSDK/FacebookSDK.h>

@interface RCHomeViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    IBOutlet UILabel *lblMessage;
    IBOutlet UILabel *borderLbl;
    IBOutlet UIImageView *spotterStatus;
    IBOutlet UIButton *btnSpotter;
    IBOutlet UITableView *tblFeeds;
    IBOutlet UIView *tblContainer;
    IBOutlet UIImageView *noAnnounceImage;
    IBOutlet UILabel *noAnnounceLbl;
    
    ASIFormDataRequest *fetchTrackRequest;
    ASIFormDataRequest *fetchEventRequest;
    ASIFormDataRequest *fetchFeedsRequest;
    ASIFormDataRequest *savePurchaseRequest;
    ASIFormDataRequest *verifyProRequest;
    ASIFormDataRequest *logoutRequest;
    ASIFormDataRequest *acknowledgeRequest;
    ASIFormDataRequest *fetchuserRequest;
    NSString *trackName;
    NSString *trackId;
    NSString *eventId;
    RCAppDelegate *appDelegate;
    NSDictionary *currentFlags;
    Reachability *internetReachability;
    NSArray *feedsArray;
    
    // Spotter Popup Stuff
    IBOutlet UIView *purchasePop;
    IBOutlet UIView *purchasePopupSubview;
    IBOutlet UILabel *purchaseTitleLbl;
    IBOutlet UILabel *purchaseMsgLbl;
    IBOutlet UIButton *buyMonthlyBtn;
    IBOutlet UIButton *buyYearlyBtn;
    IBOutlet UIButton *closePopupBtn;
    
    SKPaymentTransaction *transaction;
    
}
@property(nonatomic,retain) NSString *trackId;
@property(nonatomic,retain) NSString *eventId;
@property(nonatomic,retain) NSDictionary *currentFlags;
-(IBAction)logout:(id)sender;

@end
