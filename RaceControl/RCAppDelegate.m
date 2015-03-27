//
//  RCAppDelegate.m
//  RaceControl
//
//  Created by Jack on 4/8/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import "RCAppDelegate.h"
#import "IAPSupport.h"
#import "IAPHelper.h"
#import <FacebookSDK/FacebookSDK.h>
#import <NewRelicAgent/NewRelic.h>


@implementation RCAppDelegate
@synthesize isLocationFetched, isConnectionLost;
@synthesize purchaseInitiated,isPro,isConsumed;
@synthesize userDictionary;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [NewRelicAgent startWithApplicationToken:@"be32e34d5441fd5451a9a45e21ef6e370102c5ec"];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    /******************Registering for Push Notification*************************/
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert|
																		   UIRemoteNotificationTypeSound|
																		   UIRemoteNotificationTypeBadge)];
    
	/****************************************************************************/
    
    //pubnub configuration
    [PubNub setDelegate:self];
    [self initPubnub];
    isLocationFetched = TRUE;
    isConnectionLost = FALSE;
    self.locationMgr = [[CLLocationManager alloc] init];
    
    /*
    NSDictionary *_dict =[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
	if (_dict) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[_dict description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
         
	}
     */
    
    // Whenever a person opens the app, check for a cached session
//    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
//        NSLog(@"Found a cached session");
//        // If there's one, just open the session silently, without showing the user the login UI
//        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
//                                           allowLoginUI:NO
//                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
//                                          // Handler for session state changes
//                                          // This method will be called EACH time the session state changes,
//                                          // also for intermediate states and NOT just when the session open
//                                          [self sessionStateChanged:session state:state error:error];
//                                      }];
//        
//        // If there's no cached session, we will show a login button
//    } else {
//        UIButton *loginButton = [self.customLoginViewController loginButton];
//        [loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
//    }

    [self startStandardUpdates];
    
    return YES;
}


// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        NSLog(@"Session opened");
        // Show the user the logged-in UI
        [self userLoggedIn];
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        //NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
    
    // Handle errors
    if (error){
        //NSLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = @"Something went wrong";
            alertText = [FBErrorUtility userMessageForError:error];
            
            [self showMessage:alertText withTitle:alertTitle];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                
                // Handle session closures that happen outside of the app
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                [self showMessage:alertText withTitle:alertTitle];
                
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                [self showMessage:alertText withTitle:alertTitle];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self userLoggedOut];
    }
}

// Show the user the logged-out UI
- (void)userLoggedOut
{
    // Set the button title as "Log in with Facebook"
//    UIButton *loginButton = [self.customLoginViewController loginButton];
//    [loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
    
    // Confirm logout message
    [self showMessage:@"You're now logged out" withTitle:@""];
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
    // Set the button title as "Log out"
//    UIButton *loginButton = self.customLoginViewController.loginButton;
//    [loginButton setTitle:@"Log out" forState:UIControlStateNormal];
    
    // Welcome message
    [self showMessage:@"You're now logged in" withTitle:@"Welcome!"];
    
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title {
    [[[UIAlertView alloc] initWithTitle:title
                                message:text
                               delegate:self
                      cancelButtonTitle:@"OK!"
                      otherButtonTitles:nil] show];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// In order to process the response you get from interacting with the Facebook login process,
// you need to override application:openURL:sourceApplication:annotation:
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}
#pragma mark -
#pragma mark Push Notification management

-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	NSString *token=[NSString stringWithFormat:@"%@",deviceToken];
	token=[token stringByReplacingOccurrencesOfString:@"<" withString:@""];
	token=[token stringByReplacingOccurrencesOfString:@">" withString:@""];
	token=[token stringByReplacingOccurrencesOfString:@" " withString:@""];
	//NSLog(@"%@",token);
	[[NSUserDefaults standardUserDefaults] setObject:token forKey:DEVICE_TOKEN];
}

-(void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
	/*
	 NSString *str = [NSString stringWithFormat:@"Error: %@",err];
	 //NSLog(@"%@",str);
	 */
}


-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    /*UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[userInfo description] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
     [alert show];*/

    [[NSNotificationCenter defaultCenter]postNotificationName:PUSH_MESSAGE_NOTIFICATION object:userInfo];
}


#pragma mark -

#pragma mark - Location Manager functions

- (void)startStandardUpdates {
    self.locationMgr.delegate = self;
    self.locationMgr.distanceFilter = 50000;
    
    if ([self.locationMgr respondsToSelector:@selector(requestWhenInUseAuthorization)])
        [self.locationMgr requestWhenInUseAuthorization];
    
    [self.locationMgr startUpdatingLocation];
    
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    /*
	if (status == kCLAuthorizationStatusAuthorized) {
		NSLog(@"GPS fetching authorized..");
	}
    else if(status == kCLAuthorizationStatusDenied)
    {
        isLocationFetched = FALSE;
        NSLog(@"GPS fetching denied..");
    }
    else if(status == kCLAuthorizationStatusRestricted)
    {
        isLocationFetched = FALSE;
        NSLog(@"GPS fetching restricted..");
    }
   */
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	
	// test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0)
	{
		//NSLog(@"horizontal accuracy not enough ....");
		return;
	}
    // test the age of the location measurement to determine if the measurement is cached
    // in most cases you will not want to rely on cached measurements
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0)
	{
		//NSLog(@"cached location is coming so ignoring ....");
		return;
	}
	self.location = newLocation;
    isLocationFetched = TRUE;
	[self.locationMgr stopUpdatingLocation];
}


-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	NSLog(@"ERROR %@",error);
    isLocationFetched = FALSE;
	[self.locationMgr stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray *)_locations
{
    self.location = [_locations lastObject];
    NSLog(@"Locations AppDelegate: %@", self.location);
}

#pragma mark

-(void) subscribeToChannel:(NSString *)channelName
{
    
    PNChannel * _channel = [PNChannel channelWithName:channelName shouldObservePresence:YES];
    [PubNub subscribeOnChannel:_channel];
    
}

-(void)initPubnub
{
    
    //pubnub functions
    self.pubnubConfig = [PNConfiguration configurationForOrigin:PUBNUB_ORIGIN
                                                     publishKey:PUBNUB_PUBLISH_KEY
                                                   subscribeKey:PUBNUB_SUBSCRIBE_KEY
                                                      secretKey:PUBNUB_SECRET_KEY];
    
   // self.pubnubConfig = [PNConfiguration configurationForOrigin:@"pubsub.pubnub.com"  publishKey:@"demo" subscribeKey:@"demo" secretKey:@"demo"];
    
    [PubNub setConfiguration:self.pubnubConfig];
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        
        PNLog(PNLogGeneralLevel, self, @"{BLOCK} PubNub client connected to: %@", origin);
    }                         errorBlock:^(PNError *connectionError) {
        
        if (connectionError.code == kPNClientConnectionFailedOnInternetFailureError) {
            PNLog(PNLogGeneralLevel, self, @"Connection will be established as soon as internet connection will be restored");
        }
    }];
}





#pragma mark - pubnub delegate

- (void)pubnubClient:(PubNub *)client didReceivePushNotificationEnabledChannels:(NSArray *)channels {
    
    //NSLog(@"%@", [channels description]);
}

- (void)pubnubClient:(PubNub *)client error:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client report that error occurred: %@", error);
}

- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client is about to connect to PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully connected to PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client was unable to connect because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client willDisconnectWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub clinet will close connection because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisconnectWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client closed connection because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client disconnected from PubNub origin at: %@", origin);
}

- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully subscribed on channels: %@", channels);
    [[NSNotificationCenter defaultCenter]postNotificationName:CHANNEL_SUBSCRIPTION_SUCCESS_NOTIFICATION object:nil];
}

- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to subscribe because of error: %@", error);
    [[NSNotificationCenter defaultCenter]postNotificationName:CHANNEL_SUBSCRIPTION_FAILED_NOTIFICATION object:nil];
}

- (void)pubnubClient:(PubNub *)client didUnsubscribeOnChannels:(NSArray *)channels {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client successfully unsubscribed from channels: %@", channels);
}

- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to unsubscribe because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client didReceiveTimeToken:(NSNumber *)timeToken {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client recieved time token: %@", timeToken);
}

- (void)pubnubClient:(PubNub *)client timeTokenReceiveDidFailWithError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to receive time token because of error: %@", error);
}

- (void)pubnubClient:(PubNub *)client willSendMessage:(PNMessage *)message {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client is about to send message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)message withError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to send message '%@' because of error: %@", message, error);
}

- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)message {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client sent message: %@", message);
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client received message: %@", message);
    
    [[NSNotificationCenter defaultCenter]postNotificationName:CHANNEL_MSG_NOTIFICATION object:message];
        //this is function to recv msg from pubnub
    
    

    
}

- (void)pubnubClient:(PubNub *)client didReceivePresenceEvent:(PNPresenceEvent *)event {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client received presence event: %@", event);
}

- (void)pubnubClient:(PubNub *)client
didReceiveMessageHistory:(NSArray *)messages
          forChannel:(PNChannel *)channel
        startingFrom:(NSDate *)startDate
                  to:(NSDate *)endDate {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client received history for %@ starting from %@ to %@: %@",
          channel, startDate, endDate, messages);
}

- (void)pubnubClient:(PubNub *)client didFailHistoryDownloadForChannel:(PNChannel *)channel withError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download history for %@ because of error: %@",
          channel, error);
}

- (void)      pubnubClient:(PubNub *)client
didReceiveParticipantsLits:(NSArray *)participantsList
                forChannel:(PNChannel *)channel {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client received participants list for channel %@: %@",
          participantsList, channel);
}

- (void)                     pubnubClient:(PubNub *)client
didFailParticipantsListDownloadForChannel:(PNChannel *)channel
                                withError:(PNError *)error {
    
    PNLog(PNLogGeneralLevel, self, @"PubNub client failed to download participants list for channel %@ because of error: %@",
          channel, error);
}
- (BOOL)shouldRunClientInBackground;
{
    return YES;
}
- (NSNumber *)shouldResubscribeOnConnectionRestore {
    
    return @(YES);
}
- (NSNumber *)shouldReconnectPubNubClient:(PubNub *)client;
{
    return @(YES);
}

@end
