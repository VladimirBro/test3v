//
//  RCFlagViewController.m
//  RaceControl
//
//  Created by Jack on 4/8/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import "RCFlagViewController.h"
#import "RCHomeViewController.h"
#import "RCMotionDetector.h"

#import "RCAlertView.h"

#define kCMDeviceMotionUpdateFrequency (1.f/30.f)

@interface RCFlagViewController () <RCMotionDetectorDelegate>
{
    NSTimer *trackingTimer;
}

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *isShakingLabel;
@property (strong, nonatomic) IBOutlet UIView *popUpView;
@property (strong, nonatomic) IBOutlet UIButton *alrightBtn;

- (IBAction)alrightBtnPressed:(id)sender;

@end


@implementation RCFlagViewController
@synthesize currentFlags, homeViewController, trackId, eventId;

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
    
    [self initDetection];
    
    appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
    //lblMessage.text = NSLocalizedString(@"FETCH_TRACK",nil);
    flagsView.backgroundColor = [UIColor clearColor];
    isFlashing = FALSE;
    isWaving = FALSE;
    //[self.navigationItem setHidesBackButton:YES];
    //[self fetchTrack];
    if (appDelegate.isConnectionLost) {
        lblMessage.hidden = NO;
    } else {
        lblMessage.hidden = YES;
    }
    trackingTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(sendTracking:) userInfo:nil repeats:YES];
    [self showFlags:self.currentFlags];
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    // hide navigation bar
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.navigationController.navigationBarHidden=YES;
    
    [self registerForNotifications];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [self unregisterForNotifications];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self stopTracking];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startTracking];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self resignFirstResponder];
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self showFlags:currentFlags];
}

- (void)didReceiveMemoryWarning
{
    [self stopTracking];
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelSubscribed) name:CHANNEL_SUBSCRIPTION_SUCCESS_NOTIFICATION object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelSubscriptionFailed)name:CHANNEL_SUBSCRIPTION_FAILED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flagMessageRecieved:)name:CHANNEL_MSG_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityStatusChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}


-(void)unregisterForNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CHANNEL_SUBSCRIPTION_SUCCESS_NOTIFICATION object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:CHANNEL_SUBSCRIPTION_FAILED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANNEL_MSG_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
}


-(void)sendTracking:(NSTimer *)timer
{
    if ([RCSupport isNetworkAvaialble])
    {
        
        double speed = appDelegate.location.speed;//meters per second.
        speed = speed * 0.000621371;//miles per second
        speed = speed / (60*60);//miles per hour
        
        
        NSString *url = [NSString stringWithFormat:@"%@?userID=%@&eventID=%@&trackID=%@&lon=%lf&lat=%lf&speed=%lf&dateEpochMillis=%.0lf",
                        API_TRACK_FEEDS,
                         [appDelegate.userDictionary objectForKey:@"id"],
                         eventId,
                         trackId,
                         appDelegate.location.coordinate.longitude,
                         appDelegate.location.coordinate.latitude,
                         speed,
                         [[NSDate date] timeIntervalSince1970]];
        //NSLog(@"URL : %@",url);
        trackrequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
        //[trackrequest setDelegate:self];
        [trackrequest setRequestMethod:@"POST"];

//        if (appDelegate.userDictionary) {
//            [trackrequest setPostValue:[appDelegate.userDictionary objectForKey:@"id"] forKey:@"userID"];
//        }
//        
//        [trackrequest setPostValue:eventId forKey:@"eventID"];
//        [trackrequest setPostValue:trackId forKey:@"trackID"];
//        [trackrequest setPostValue:[NSString stringWithFormat:@"%lf",appDelegate.location.coordinate.longitude] forKey:@"lon"];
//        [trackrequest setPostValue:[NSString stringWithFormat:@"%lf",appDelegate.location.coordinate.latitude] forKey:@"lat"];
//        [trackrequest setPostValue:[NSString stringWithFormat:@"%lf",appDelegate.location.speed] forKey:@"speed"];
//        [trackrequest setPostValue:[NSString stringWithFormat:@"%lf",[[NSDate date] timeIntervalSince1970]] forKey:@"dateEpochMillis"];
        
        [trackrequest startAsynchronous];
 
    }
}

- (void)fetchTrack
{
    for (UIView *v in flagsView.subviews) {
        [v.layer removeAllAnimations];
        [v removeFromSuperview];
    }
    if (!appDelegate.isLocationFetched) {
        //lblMessage.text = @"Sorry, your GPS location could not be fetched. Make sure location services are enalbed under Settings.";
        
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
        //NSLog(@"URL : %@",[url absoluteString]);
        fetchTrackRequest=[ASIFormDataRequest requestWithURL:url];
        [fetchTrackRequest setDelegate:self];
        [fetchTrackRequest setRequestMethod:@"GET"];
        [fetchTrackRequest startAsynchronous];
    }
}

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
        // NSLog(@"URL : %@",[url absoluteString]);
        fetchEventRequest=[ASIFormDataRequest requestWithURL:url];
        [fetchEventRequest setDelegate:self];
        [fetchEventRequest setRequestMethod:@"GET"];
        [fetchEventRequest startAsynchronous];
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
    [SVProgressHUD dismiss];
    NSString *response = [request responseString];
    id respJSON = [response JSONValue];
    //NSLog(@"RESP : %@",respJSON);
    if (request == fetchTrackRequest) {
        if ([respJSON isKindOfClass:[NSDictionary class]]) {
            trackName = [respJSON valueForKey:@"name"];
            trackId = [respJSON valueForKey:@"id"];
            /*lblMessage.text = [NSString stringWithFormat:@"Connecting to latest event at track : \n%@",
             trackName];*/
            [self fetchEvent:trackId];
        }
        else
        {
            //lblMessage.text = NSLocalizedString(@"NO_TRACK",nil);
        }
    }
    else if (request == fetchEventRequest)
    {
        if ([respJSON isKindOfClass:[NSDictionary class]])
        {
            eventId = [respJSON valueForKey:@"id"];
            [appDelegate subscribeToChannel:eventId];
            [self showFlags:respJSON];
            [self sendAcknowledgement:eventId];
        }
        else
        {
            //lblMessage.text = [NSString stringWithFormat:@"Could not connect to latest event at track : \n%@",trackName];
        }
    }
    else if (request == acknowledgeRequest)
    {
       
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
}


-(void)channelSubscribed
{
    //lblMessage.text = [NSString stringWithFormat:@"Connected to latest event at track : \n%@",                       trackName];
}

-(void)channelSubscriptionFailed
{
    //lblMessage.text = [NSString stringWithFormat:@"Could not connect to latest event at track : \n%@",trackName];
}


-(void)flagMessageRecieved:(NSNotification*)notif
{
    PNMessage *flag = notif.object;
    [self startFlash:self.view];
    [self performSelector:@selector(stopFlash:) withObject:self.view afterDelay:4.0f];
    //NSLog(@"Event Id : %@",[flag.message valueForKey:@"eventid"]);
    [self showFlags:flag.message];
}


-(void)showFlags:(id)flag
{
    //NSLog(@"Message : %@",flag);
    currentFlags = flag;
    isWaving = FALSE;
    for (UIView *v in flagsView.subviews) {
        [v.layer removeAllAnimations];
        [v removeFromSuperview];
    }
    
    //Adding global flag....
    int xGap = 2;
    int yGap = 5;
    float height = (flagsView.frame.size.height-yGap)/2;
    NSDictionary *globalFlag = [flag valueForKey:@"globalMessage"];
    NSLog(@"globalFlag=%@", globalFlag.description);
    
    if (globalFlag) {
        RCFlagView *globalFlagView = [[RCFlagView alloc] initWithFrame:CGRectMake(xGap, 0, flagsView.frame.size.width-xGap*2, height)];
        NSString *color = [[globalFlag valueForKey:@"color"] uppercaseString];
        globalFlagView.color = [UIColor_String colorWithString:color];
        globalFlagView.backgroundColor = globalFlagView.color;
        
        if([color isEqualToString:@"RESTART"])
        {
            globalFlagView.image = [UIImage imageNamed:@"restart_flag.png"];
        }
        else if([color isEqualToString:@"FINISH"])
        {
            globalFlagView.image = [UIImage imageNamed:@"finish_flag.png"];
        }
        else if([color isEqualToString:@"YELLOW"])
        {
            globalFlagView.image = [UIImage imageNamed:@"yellow_flag.png"];
        }
        else if([color isEqualToString:@"BLACK"])
        {
            globalFlagView.layer.borderColor = FLAG_BORDER_COLOR.CGColor;
            globalFlagView.layer.borderWidth = 2.0f;;
        }
        //NSLog(@"globalFlagView : %@",NSStringFromCGSize(globalFlagView.frame.size));
        [flagsView addSubview:globalFlagView];
    }
    
    int  safteyFlag = [[flag valueForKey:@"safteyFlag"] integerValue];
    if (safteyFlag) {
        //NSLog(@"safteyFlag : %d",safteyFlag);
        safetyFlagView = [[RCFlagView alloc] initWithFrame:CGRectMake(0, 0, 150, 75)];
        safetyFlagView.image = [UIImage imageNamed:@"safety_flag.png"];
        safetyFlagView.layer.borderColor = [UIColor blackColor].CGColor;
        safetyFlagView.layer.borderWidth = 2.0f;
        [flagsView addSubview:safetyFlagView];
    }
    
    NSDictionary *localFlag;
    RCFlagView *localFlagView;
    
    NSArray *localFlags = [flag objectForKey:@"localFlags"];
    
    
    int count = [localFlags count];
    float width = (flagsView.frame.size.width-(count+1)*xGap)/count;
    
    if (!globalFlag && safteyFlag == 0 && count == 0) {
        noFlags.hidden = NO;
    }
    else
    {
        noFlags.hidden = YES;
    }
    
    for (int i = 0 ; i < [localFlags count]; i++) {
        localFlag = [localFlags objectAtIndex:i];
        localFlagView = [[RCFlagView alloc] initWithFrame:CGRectMake(i*width+(xGap*(i+1)), height+yGap, width, height)];
        localFlagView.color = [UIColor_String colorWithString:[localFlag valueForKey:@"color"]];
        localFlagView.number.text = [[localFlag valueForKey:@"number"] stringValue];
        localFlagView.backgroundColor = localFlagView.color;
        [flagsView addSubview:localFlagView];
        int  waving = [[localFlag valueForKey:@"isWaving"] integerValue];
        if (waving==1) {
            //NSLog(@"waving : %d",waving);
            isWaving = TRUE;
            [self startWaving:localFlagView];
        }
    }
}



-(IBAction)refresh:(id)sender
{
    [self fetchTrack];
}


/**** To start waving flag on recieving pubnub message ****/
-(void)startWaving:(UIView *)flag
{
	[self blinkAnimation:@"blinkAnimation" finished:TRUE target:flag];
}

/**** To stop waving of flag ****/
-(void)stopWaving:(UIView *)flag
{
    isWaving = FALSE;
	[flag setAlpha:1.0f];
}


/**** To start waving flag on recieving pubnub message ****/
- (void)blinkAnimation:(NSString *)animationId finished:(BOOL)finished target:(UIView *)target
{
    if (!isWaving) {
        return;
    }
    //[target setAlpha:1.0f];
    [UIView animateWithDuration:0.2
                          delay:0.0
                        options:UIViewAnimationOptionRepeat |
     UIViewAnimationOptionAutoreverse |
     UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         //[target setAlpha:0.0f];
                         [target setBackgroundColor:[UIColor blackColor]];
                     }
                     completion:^(BOOL finished){
                         // Do nothing
                     }];
    
    /*
     [UIView beginAnimations:animationId context:(__bridge void *)(target)];
     [UIView setAnimationDuration:0.2f];
     [UIView setAnimationDelegate:self];
     [UIView setAnimationDidStopSelector:@selector(blinkAnimation:finished:target:)];
     if ([target alpha] == 1.0f)
     [target setAlpha:0.0f];
     else
     [target setAlpha:1.0f];
     [UIView commitAnimations];
     */
}

/**** To flash borders on track state change ****/
-(void)startFlash:(UIView *)view
{
    if (!isFlashing) {
        isFlashing = TRUE;
        [self flashAnimation:@"flashAnimation" finished:isFlashing target:view];
    }
	
}

/**** To stop flashing borders ****/
-(void)stopFlash:(UIView *)view
{
    isFlashing = FALSE;
	[view setBackgroundColor:[UIColor blackColor]];
}


/**** To start waving flag on recieving pubnub message ****/
- (void)flashAnimation:(NSString *)animationId finished:(BOOL)finished target:(UIView *)target
{
    
    if (isFlashing) {
        [UIView beginAnimations:animationId context:(__bridge void *)(target)];
        [UIView setAnimationDuration:0.2f];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(flashAnimation
                                                      :finished:target:)];
        if ([target backgroundColor] == [UIColor blackColor])
            [target setBackgroundColor:[UIColor whiteColor]];
        else
            [target setBackgroundColor:[UIColor blackColor]];
        [UIView commitAnimations];
    }
}

-(void)reachabilityStatusChanged:(NSNotification*)note
{
    NSLog(@"reachabilityChanged");
    
    Reachability * reach = [note object];
    
    if([reach currentReachabilityStatus] == NotReachable)
    {
        appDelegate.isConnectionLost = TRUE;
        lblMessage.hidden = NO;
    }
    else
    {
        appDelegate.isConnectionLost = FALSE;
        lblMessage.hidden = YES;
        [self refresh:nil];
    }
}

-(IBAction)popViewController:(id)sender
{
    if ([trackingTimer isValid]) {
        [trackingTimer invalidate];
        trackingTimer = nil;
    }
    //[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToViewController:self.homeViewController animated:YES];
}


#pragma mark - init Detection
#pragma mark Speed Handling

- (void)initDetection {
    
    __weak RCFlagViewController *weakSelf = self;
    weakSelf.popUpView.layer.cornerRadius = 5.0f;
    weakSelf.popUpView.clipsToBounds = YES;
    weakSelf.alrightBtn.layer.borderColor = [UIColor orangeColor].CGColor;
    weakSelf.alrightBtn.layer.borderWidth = 2.0f;
    weakSelf.alrightBtn.layer.cornerRadius = 5.0f;
    weakSelf.alrightBtn.clipsToBounds = YES;
    
    [RCMotionDetector sharedInstance].locationChangedBlock = ^(CLLocation *location) {
        weakSelf.speedLabel.text = [NSString stringWithFormat:@"%.2f km/h",[RCMotionDetector sharedInstance].currentSpeed * 3.6f];
    };
    
    [weakSelf.popUpView setHidden:YES];
    [RCMotionDetector sharedInstance].accelerationChangedBlock = ^(CMAcceleration acceleration) {
        BOOL isShaking = [RCMotionDetector sharedInstance].isShaking;
        weakSelf.isShakingLabel.text = isShaking ? @"shaking" : @"not shaking";
        if (isShaking) {
            [weakSelf.popUpView setHidden:NO];
            [weakSelf.speedLabel setHidden:YES];
            [weakSelf.isShakingLabel setHidden:NO];
        } else {
            [weakSelf.speedLabel setHidden:NO];
            [weakSelf.isShakingLabel setHidden:YES];
        }
    };
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [RCMotionDetector sharedInstance].useM7IfAvailable = YES; //Use M7 chip if available, otherwise use lib's algorithm
    }
}

- (void)showAlert {
    
}

- (void)showAlertWithText:(NSString*)text title:(NSString*)title {
    [RCAlertView showWithTitle:title andText:text andFirstButtonTitle:@"OK" andSecondButtonTitle:nil andPrompt:nil andCompletionHandler:^(NSInteger clickedButtonIndex, NSString *promptString) {
        
    }];
}


- (void) startTracking {
    printf("[StartTracking]\n");
    [[RCMotionDetector sharedInstance] startDetection];
}

- (void) stopTracking {
    printf("[StopTracking]\n");
    [[RCMotionDetector sharedInstance] stopDetection];
}


#pragma mark - Orientation Handling

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationLandscapeLeft));
}

- (BOOL)shouldAutorotate  // iOS 6 autorotation fix
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations // iOS 6 autorotation fix
{
    return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft);
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation // iOS 6 autorotation fix
{
    return (UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationLandscapeLeft);
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft)
    {
        
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationPortrait)
    {
        
    }
}


- (IBAction)alrightBtnPressed:(id)sender {
    printf("alrightBtnPressed\n");
    [self.popUpView setHidden:YES];
}
@end
