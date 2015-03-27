//
//  RCHomeViewController.m
//  RaceControl
//
//  Created by Sabir on 4/26/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import "RCHomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RCSettingsViewController.h"

@interface RCHomeViewController ()

@end

@implementation RCHomeViewController
@synthesize trackId,eventId,currentFlags;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
    spotterStatus.image = [UIImage imageNamed:@"status_not_connected_icon.png"];
    lblMessage.text = NSLocalizedString(@"FETCH_TRACK",nil);
    [self.navigationItem setHidesBackButton:YES];
    currentFlags = nil;
    //btnSpotter.enabled = NO;
    
    UIImageView *titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,137,20)];
    [titleView setBackgroundColor:[UIColor clearColor]];
    [titleView setImage:[UIImage imageNamed:@"spotter_logo.png"]];
    self.navigationItem.titleView = titleView;
    titleView = nil;
    
    [self registerForNotifications];
    internetReachability = [Reachability reachabilityForInternetConnection];
    [internetReachability startNotifier];
    
    noAnnounceLbl.text = NSLocalizedString(@"NO_ANNOUNCEMENT", nil);
    tblFeeds.hidden = true;
    noAnnounceImage.hidden = false;
    noAnnounceLbl.hidden = false;
    
    //[self verifyProUser];
    [self fetchUser];
    [self fetchTrack];
}

-(void)viewWillAppear:(BOOL)animated
{
    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    [navigationBar setBarTintColor:BLACK_COLOR];
    [navigationBar setTranslucent:NO];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    self.navigationController.navigationBarHidden=NO;
    //[self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"refresh_button.png"]];
    
    
    tblContainer.layer.borderWidth = 1.0;
    tblContainer.layer.borderColor = grayColor;
    tblContainer.layer.cornerRadius = 5.0;
    
    borderLbl.layer.borderWidth = 1.0;
    borderLbl.layer.borderColor = grayColor;
    borderLbl.layer.cornerRadius = 5.0;
}

-(void)viewDidAppear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelSubscribed) name:CHANNEL_SUBSCRIPTION_SUCCESS_NOTIFICATION object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelSubscriptionFailed)name:CHANNEL_SUBSCRIPTION_FAILED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flagMessageRecieved:)name:CHANNEL_MSG_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshFeeds:)
                                                 name:PUSH_MESSAGE_NOTIFICATION
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityStatusChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    [self registerForPurchaseNotifications];
    
}


-(void)unregisterForNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CHANNEL_SUBSCRIPTION_SUCCESS_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CHANNEL_SUBSCRIPTION_FAILED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANNEL_MSG_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PUSH_MESSAGE_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    [self unregisterForPurchaseNotifications];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:SEGUE_ID_SPOTTER_FROM_HOME]) {
        RCFlagViewController *destinationViewController = (RCFlagViewController*)[segue destinationViewController];
        destinationViewController.currentFlags = currentFlags;
        destinationViewController.eventId = self.eventId;
        destinationViewController.trackId = self.trackId;
        destinationViewController.homeViewController = self;
    }
    else if ([[segue identifier] isEqualToString:SEGUE_ID_SettingsFromHome]) {
        RCSettingsViewController *viewController = (RCSettingsViewController *) [segue destinationViewController];
        viewController.homeViewController = self;
    }
    else if ([[segue identifier] isEqualToString:SEGUE_ID_CarFromHome])
    {
        RCCarTableViewController *destinationViewController = (RCCarTableViewController*)[segue destinationViewController];
        destinationViewController.homeViewController = self;
    }
}


- (void)fetchUser
{
    if ([RCSupport isNetworkAvaialble])
    {
        NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:ACCESS_TOKEN];
        accessToken = [accessToken stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSURL *url = [NSURL URLWithString:
                      [NSString stringWithFormat:@"%@?&access_token=%@",API_USER_REGISTER,accessToken]];
        //NSLog(@"URL : %@",[url absoluteString]);
        fetchuserRequest=[ASIFormDataRequest requestWithURL:url];
        [fetchuserRequest setDelegate:self];
        [fetchuserRequest setRequestMethod:@"GET"];
        [fetchuserRequest startAsynchronous];
    }
}

- (void)fetchTrack
{
    if (!appDelegate.isLocationFetched) {
        spotterStatus.image = [UIImage imageNamed:@"status_not_connected_icon.png"];
        lblMessage.text = @"Sorry, your GPS location could not be fetched. Make sure location services are enabled under Settings.";
        
        return;
    }
    
    if ([RCSupport isNetworkAvaialble])
    {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil) maskType:SVProgressHUDMaskTypeBlack];
        
        NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:ACCESS_TOKEN];
        accessToken = [accessToken stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        //NSLog(@"accessToken : %@",accessToken);
        NSURL *url = [NSURL URLWithString:
                      [NSString stringWithFormat:@"%@?lat=%lf&long=%lf&distance=%@&access_token=%@",
                       API_GET_TRACK,
                       appDelegate.location.coordinate.latitude,//-122.1501887217164f,
                       appDelegate.location.coordinate.longitude,//37.85307831130922f,
                       DISTANCE_RADIUS,
                       accessToken]];
        NSLog(@"fetchTrack=URL : %@",[url absoluteString]);
        fetchTrackRequest=[ASIFormDataRequest requestWithURL:url];
        [fetchTrackRequest setDelegate:self];
        [fetchTrackRequest setRequestMethod:@"GET"];
        [fetchTrackRequest startAsynchronous];
        
        /*
        [self updateTracks];
         */
    }
}


#pragma mark - for testing UPDATE_TRACKS
- (void) updateTracks {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil) maskType:SVProgressHUDMaskTypeBlack];
    NSString * UPDATE_TRACKS = @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/spotter/updatetracks";
    NSNumber * spotterkey = [NSNumber numberWithInt:1212];
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:
                                        @"%@?spotterkey=%@", UPDATE_TRACKS, spotterkey]];
    NSLog(@"fetchTrack=URL : %@",[url absoluteString]);
    fetchTrackRequest=[ASIFormDataRequest requestWithURL:url];
    [fetchTrackRequest setDelegate:self];
    [fetchTrackRequest setRequestMethod:@"GET"];
    [fetchTrackRequest startAsynchronous];
}
#pragma mark


- (void)fetchEvent:(NSString*)_trackId
{
    if ([RCSupport isNetworkAvaialble])
    {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil) maskType:SVProgressHUDMaskTypeBlack];
        
        NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:ACCESS_TOKEN];
        accessToken = [accessToken stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSURL *url = [NSURL URLWithString:
                      [NSString stringWithFormat:@"%@?lat=%lf&long=%lf&trackid=%@&access_token=%@",
                       API_GET_EVENT,
                       appDelegate.location.coordinate.latitude,//-122.1501887217164f,
                       appDelegate.location.coordinate.longitude,//37.85307831130922f,
                       _trackId,
                       accessToken]];
        NSLog(@"URL : %@",[url absoluteString]);
        fetchEventRequest=[ASIFormDataRequest requestWithURL:url];
        [fetchEventRequest setDelegate:self];
        [fetchEventRequest setRequestMethod:@"GET"];
        [fetchEventRequest startAsynchronous];
    }
    
}


- (void)fetchFeeds:(NSString*)_trackId :(BOOL)indicator
{
    if ([RCSupport isNetworkAvaialble])
    {
        if (indicator)
            [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil) maskType:SVProgressHUDMaskTypeBlack];
        
        NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:ACCESS_TOKEN];
        accessToken = [accessToken stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSURL *url = [NSURL URLWithString:
                      [NSString stringWithFormat:@"%@?senderid=%@&limit=%d&access_token=%@",
                       API_GET_FEED,
                       _trackId,
                       50,
                       accessToken]];
        
        
        //NSLog(@"URL : %@",[url absoluteString]);
        fetchFeedsRequest=[ASIFormDataRequest requestWithURL:url];
        [fetchFeedsRequest setDelegate:self];
        [fetchFeedsRequest setRequestMethod:@"GET"];
        [fetchFeedsRequest startAsynchronous];
    }
    
}

- (void)sendAcknowledgement:(NSString*)_eventId
{
    if ([RCSupport isNetworkAvaialble])
    {
        NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:ACCESS_TOKEN];
        accessToken = [accessToken stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSMutableString *_url = [NSMutableString stringWithFormat:@"%@?access_token=%@&eventid=%@",
                                 API_ACKNOWLEDGEMENT,
                                 accessToken,
                                 _eventId];
        // &locals=yellow;4;waving,yellow;8;standing&global=red&safety=safety
        NSDictionary *globalFlag = [currentFlags valueForKey:@"globalMessage"];
        if (globalFlag) {
            
            NSString *color = [[globalFlag valueForKey:@"color"] lowercaseString];
            [_url appendFormat:@"&global=%@",color];
        }
        int  safteyFlag = [[currentFlags valueForKey:@"safteyFlag"] integerValue];
        if (safteyFlag) {
            [_url appendString:@"&safety=safety"];
        }
        
        NSArray *localFlags = [currentFlags objectForKey:@"localFlags"];
        int count = [localFlags count];
        
        NSString *str;
        NSDictionary *localFlag;
        for (int i = 0 ; i < count; i++) {
            localFlag = [localFlags objectAtIndex:i];
            str = [NSString stringWithFormat:@"%@;%@;%@",
                   [[localFlag valueForKey:@"color"] lowercaseString],
                   [[localFlag valueForKey:@"number"] stringValue],
                   ([[localFlag valueForKey:@"isWaving"] integerValue]?@"waving":@"standing")];
            if (i == 0) {
                [_url appendFormat:@"&locals=%@",str];
            }
            else
            {
                [_url appendFormat:@",%@",str];
            }
        }
        NSLog(@"URL : %@",_url);
        NSURL *url = [NSURL URLWithString:_url];
        //NSLog(@"URL : %@",[url absoluteString]);
        acknowledgeRequest=[ASIFormDataRequest requestWithURL:url];
        [acknowledgeRequest setDelegate:self];
        [acknowledgeRequest setRequestMethod:@"GET"];
        [acknowledgeRequest startAsynchronous];
    }
    
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    id respJSON = [response JSONValue];
    NSLog(@"RESP HomeVC: %@",respJSON);
    if (request == fetchuserRequest) {
        appDelegate.userDictionary = [NSMutableDictionary dictionaryWithDictionary:respJSON];
    }
    else
    {
        [SVProgressHUD dismiss];
        if (request == fetchTrackRequest) {
            if ([respJSON isKindOfClass:[NSDictionary class]]) {
                trackName = [respJSON valueForKey:@"name"];
                trackId = [respJSON valueForKey:@"id"];
                spotterStatus.image = [UIImage imageNamed:@"status_connected_icon.png"];
                lblMessage.text = [NSString stringWithFormat:@"Connecting to latest event at track : \n%@",
                                   trackName];
                [self fetchEvent:trackId];
            }
            else
            {
                spotterStatus.image = [UIImage imageNamed:@"status_not_connected_icon.png"];
                lblMessage.text = NSLocalizedString(@"NO_TRACK",nil);
            }
        }
        else if (request == fetchEventRequest)
        {
            //btnSpotter.enabled = YES;
            if ([respJSON isKindOfClass:[NSDictionary class]])
            {
                eventId = [respJSON valueForKey:@"id"];
                [appDelegate subscribeToChannel:eventId];
                //[self showFlags:respJSON];
                currentFlags = respJSON;
                [self sendAcknowledgement:eventId];
            }
            else
            {
                spotterStatus.image = [UIImage imageNamed:@"status_not_connected_icon.png"];
                lblMessage.text = [NSString stringWithFormat:@"Could not connect to latest event at track : \n%@",trackName];
            }
            [self fetchFeeds:trackId :TRUE];
        }
        else if (request == fetchFeedsRequest)
        {
            if ([respJSON isKindOfClass:[NSArray class]]) {
                feedsArray = respJSON;
            }
            else
            {
                feedsArray = nil;
            }
            
            if(feedsArray.count > 0)
            {
                tblFeeds.hidden = false;
                noAnnounceImage.hidden = true;
                noAnnounceLbl.hidden = true;
            }
            else
            {
                noAnnounceLbl.text = NSLocalizedString(@"NO_ANNOUNCEMENT", nil);
                tblFeeds.hidden = true;
                noAnnounceImage.hidden = false;
                noAnnounceLbl.hidden = false;
            }
            [tblFeeds reloadData];
            
        }
        else if (request == savePurchaseRequest)
        {
            if([respJSON isKindOfClass:[NSDictionary class]])
            {
                if([[respJSON valueForKey:@"isPro"] integerValue])
                {
                    appDelegate.isPro = TRUE;
                    [self performSelector:@selector(closePurchasePopup:) withObject:nil];
                    [self performSelector:@selector(startSpotter:) withObject:nil];
                }
                else
                {
                    appDelegate.isPro = FALSE;
                }
                if([[respJSON valueForKey:@"consume"] integerValue])
                {
                    appDelegate.isConsumed = TRUE;
                }
                else
                {
                    appDelegate.isConsumed = FALSE;
                }
            }
        }
        else if (request == verifyProRequest)
        {
            if([respJSON isKindOfClass:[NSDictionary class]])
            {
                if([[respJSON valueForKey:@"isPro"] integerValue])
                {
                    appDelegate.isPro = TRUE;
                }
                else
                {
                    appDelegate.isPro = FALSE;
                    
                    /*if ([[respJSON valueForKey:@"consume"] integerValue])
                     {
                     //[[SKPaymentQueue defaultQueue] finishTransaction: transaction];
                     }
                     else
                     {
                     appDelegate.isPro = FALSE;
                     }*/
                }
            }
            [self fetchTrack];
        }
        else if(request == acknowledgeRequest)
        {
            NSLog(@"Here coming ...");
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    //NSLog(@"Req = %@",request.error);
    if (request == fetchuserRequest) {
        return;
    }
    [SVProgressHUD dismiss];
    if (request == verifyProRequest) {
        [self fetchTrack];
    }
    else if (request == fetchEventRequest) {
        [self fetchFeeds:trackId :TRUE];
    }
}


-(void)channelSubscribed
{
    spotterStatus.image = [UIImage imageNamed:@"status_connected_icon.png"];
    lblMessage.text = [NSString stringWithFormat:@"Connected to latest event at track : \n%@",
                       trackName];
}

-(void)channelSubscriptionFailed
{
    spotterStatus.image = [UIImage imageNamed:@"status_not_connected_icon.png"];
    lblMessage.text = [NSString stringWithFormat:@"Could not connect to latest event at track : \n%@",trackName];
}

-(void)flagMessageRecieved:(NSNotification*)notif
{
    PNMessage *flag = notif.object;
    NSLog(@"Event Id : %@",[flag.message valueForKey:@"id"]);
    currentFlags = flag.message;
    [self sendAcknowledgement:[flag.message valueForKey:@"id"]];
}


-(IBAction)logout:(id)sender
{
    [self unregisterForNotifications];
    
    [internetReachability stopNotifier];
    /*
    //to logout
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    
    
    if ([RCSupport isNetworkAvaialble])
    {
        //[SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil) maskType:SVProgressHUDMaskTypeBlack];
        
        NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:ACCESS_TOKEN];
        accessToken = [accessToken stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        //NSLog(@"accessToken : %@",accessToken);
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?access_token=%@",
                                           API_USER_LOGOUT,
                                           accessToken]];
        //NSLog(@"URL : %@",[url absoluteString]);
        logoutRequest=[ASIFormDataRequest requestWithURL:url];
        [logoutRequest setDelegate:nil];
        [logoutRequest setRequestMethod:@"DELETE"];
        [logoutRequest startAsynchronous];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:EMAIL_TEXT];
    [defaults removeObjectForKey:PASSWORD_TEXT];
    [defaults synchronize];
    [self.navigationController popToRootViewControllerAnimated:YES];
     */
}

-(IBAction)refresh:(id)sender
{
    [self fetchTrack];
}

- (IBAction)inviteFriends:(id)sender {
    [self performSegueWithIdentifier:SEGUE_ID_SettingsFromHome sender:self];
}

-(IBAction)startSpotter:(id)sender
{
    
    // Service purchasing by passed
    if (appDelegate.userDictionary && [appDelegate.userDictionary objectForKey:@"carnumber"]) {
        [self performSegueWithIdentifier:SEGUE_ID_SPOTTER_FROM_HOME sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:SEGUE_ID_CarFromHome sender:self];
    }
    
    
    /*
     if(appDelegate.isPro)
     {
     [self performSegueWithIdentifier:SEGUE_ID_SPOTTER_FROM_HOME sender:self];
     }
     else
     {
     // Adding observer for transactions
     [[SKPaymentQueue defaultQueue] addTransactionObserver:[IAPSupport sharedHelper]];
     
     UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:purchasePopupSubview.bounds];
     purchasePopupSubview.layer.masksToBounds = NO;
     purchasePopupSubview.layer.shadowColor = BLACK_COLOR.CGColor;
     purchasePopupSubview.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
     purchasePopupSubview.layer.shadowOpacity = 0.5f;
     purchasePopupSubview.layer.shadowPath = shadowPath.CGPath;
     
     purchaseTitleLbl.text = NSLocalizedString(@"PURCHASE_TITLE", nil);
     //purchaseMsgLbl.text = NSLocalizedString(@"PURCHASE_MSG", nil);
     
     [buyMonthlyBtn setTitle:NSLocalizedString(@"MNTHLY_TEXT", nil) forState:UIControlStateNormal];
     [buyYearlyBtn setTitle:NSLocalizedString(@"YRLY_TEXT", nil) forState:UIControlStateNormal];
     
     [buyMonthlyBtn setTitleColor:YELLOW_COLOR forState:UIControlStateNormal];
     [buyMonthlyBtn setTitleColor:YELLOW_COLOR forState:UIControlStateHighlighted];
     
     [buyYearlyBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
     
     buyMonthlyBtn.backgroundColor = [UIColor blackColor];
     buyYearlyBtn.backgroundColor = YELLOW_COLOR;
     
     //buyMonthlyBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
     //buyMonthlyBtn.layer.borderWidth = 2.0f;
     buyMonthlyBtn.layer.cornerRadius = 5.0;
     //buyYearlyBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
     //buyYearlyBtn.layer.borderWidth = 2.0f;
     buyYearlyBtn.layer.cornerRadius = 5.0;
     
     purchasePop.hidden = false;
     
     self.navigationItem.leftBarButtonItem.enabled = false;
     self.navigationItem.rightBarButtonItem.enabled = false;
     }
     */
}


-(void)reachabilityStatusChanged:(NSNotification*)note
{
    NSLog(@"reachabilityChanged");
    
    Reachability * reach = [note object];
    
    if([reach currentReachabilityStatus] == NotReachable)
    {
        appDelegate.isConnectionLost = TRUE;
        spotterStatus.image = [UIImage imageNamed:@"status_not_connected_icon.png"];
        lblMessage.text = [NSString stringWithFormat:@"Can not connect to service"];
    }
    else
    {
        appDelegate.isConnectionLost = FALSE;
        [self refresh:nil];
    }
}

-(void)refreshFeeds:(NSNotification*)notif
{
    [self fetchFeeds:trackId :FALSE];
}



#pragma mark Purchase

-(IBAction)closePurchasePopup:(id)sender
{
    self.navigationItem.leftBarButtonItem.enabled = true;
    self.navigationItem.rightBarButtonItem.enabled = true;
    purchasePop.hidden = true;
}

-(IBAction)purchaseMonthlySpotter:(id)sender
{
    [self startPurchaseWithProductId:MONTHLY_SPOTTER_ID];
}

-(IBAction)purchaseYearlySpotter:(id)sender
{
    [self startPurchaseWithProductId:YEARLY_SPOTTER_ID];
}

#pragma mark
#pragma mark -InAppPurchase

-(void)verifyProUser
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil) maskType:SVProgressHUDMaskTypeBlack];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:ACCESS_TOKEN];
    accessToken = [accessToken stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?&access_token=%@",
                                       API_VERIFY_PURCHASE,
                                       accessToken]];
    //NSLog(@"Verify URL : %@",[url absoluteString]);
    verifyProRequest=[ASIFormDataRequest requestWithURL:url];
    [verifyProRequest setDelegate:self];
    [verifyProRequest setRequestMethod:@"GET"];
    [verifyProRequest startAsynchronous];
}

-(void)savePurchase:(SKPaymentTransaction*)_transaction
{
    transaction = _transaction;
    if ([RCSupport isNetworkAvaialble])
    {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil) maskType:SVProgressHUDMaskTypeBlack];
        
        NSTimeInterval time = [_transaction.transactionDate timeIntervalSince1970];
        NSString *_time = [NSString stringWithFormat:@"%.0lf",time*1000];
        
        NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:ACCESS_TOKEN];
        accessToken = [accessToken stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *sku;
        if ([_transaction.payment.productIdentifier isEqualToString:MONTHLY_SPOTTER_ID]) {
            sku = SKU_MONTHLY;
        }
        else
        {
            sku = SKU_YEARLY;
        }
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",API_SAVE_PURCHASE]];
        //NSLog(@"Save URL : %@",url);
        
        savePurchaseRequest=[ASIFormDataRequest requestWithURL:url];
        [savePurchaseRequest setDelegate:self];
        [savePurchaseRequest setRequestMethod:@"POST"];
        [savePurchaseRequest addPostValue:sku forKey:@"sku"];
        [savePurchaseRequest addPostValue:accessToken forKey:@"access_token"];
        [savePurchaseRequest addPostValue:_time forKey:@"time"];
        [savePurchaseRequest addPostValue:_transaction.transactionIdentifier forKey:@"purchaseid"];
        [savePurchaseRequest startAsynchronous];
    }
    
}



- (void)registerForPurchaseNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
}



-(void)unregisterForPurchaseNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchasedNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kProductPurchaseFailedNotification object:nil];
}

-(void)startPurchaseWithProductId:(NSString*)productId
{
    appDelegate.purchaseInitiated = 1;
    [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil)
                         maskType:SVProgressHUDMaskTypeBlack];
    [self performSelectorInBackground:@selector(purchaseProduct:) withObject:productId];
    [self performSelector:@selector(timeout:) withObject:nil afterDelay:60*3];
}

-(void)purchaseProduct:(NSString*)productId
{
    [[IAPSupport sharedHelper] buyProductIdentifier:productId];
}


- (void)productPurchased:(NSNotification *)notification
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //[self performSelectorOnMainThread:@selector(showSuccess:) withObject:notification.object waitUntilDone:YES];
    SKPaymentTransaction *_transaction = (SKPaymentTransaction *) notification.object;
    if (appDelegate.purchaseInitiated) {
        //NSLog(@"New Purchase Transaction....");
        [self savePurchase:_transaction];
    }
    else
    {
        //NSLog(@"Consuming Purchased Transaction....");
        [[SKPaymentQueue defaultQueue] finishTransaction: _transaction];
        appDelegate.isConsumed = FALSE;
    }
}

-(void)showSuccess:(NSString*)productId
{
    [SVProgressHUD dismiss];
    [self performSelector:@selector(updateUIAfterPurchase) withObject:nil afterDelay:1.0f];
    //NSLog(@"PRODUCT ID PURCHASED : %@",productId);
}

-(void)updateUIAfterPurchase
{
    // update ui
    [SVProgressHUD dismiss];
}

- (void)productPurchaseFailed:(NSNotification *)notification
{
    appDelegate.purchaseInitiated = 0;
    [SVProgressHUD dismiss];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    SKPaymentTransaction * _transaction = (SKPaymentTransaction *) notification.object;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:_transaction.error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    
    [alert show];
}



- (void)timeout:(id)arg
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [SVProgressHUD dismiss];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [feedsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FeedCell";
    RCFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Configure the cell...
    NSDictionary *feed = [feedsArray objectAtIndex:indexPath.row];
    [cell setData:feed];
    return cell;
}


// Variable height support
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height = CELL_UPPER_MARGIN;
    
    NSDictionary *obj = [feedsArray objectAtIndex:indexPath.row];
    float textHeight = [RCSupport returnHeightOfText:[obj valueForKey:@"feed"] width:245.0f font:[UIFont systemFontOfSize:15.0f]];
    height = height + textHeight + CELL_LOWER_MARGIN;
    //NSLog(@"height : %f",height);
    if (height < CELL_MIN_HEIGHT) {
        height = CELL_MIN_HEIGHT;
    }
    return height;
}

#pragma mark
#pragma mark -Orientation Handling

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations // iOS 6 autorotation fix
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation // iOS 6 autorotation fix
{
    return UIInterfaceOrientationPortrait;
}



@end
