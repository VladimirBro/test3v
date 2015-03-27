    //
//  RCSplashViewController.m
//  RaceControl
//
//  Created by Sabir on 5/7/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import "RCSplashViewController.h"
#import "RCFacebookSignUpViewController.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"
#import "RCAppDelegate.h"

@interface RCSplashViewController ()

@property (nonatomic, strong) id <FBGraphUser> fbUserData;

@end


@implementation RCSplashViewController

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
    if([UIScreen mainScreen].bounds.size.height > 500)
        splashImage.image =[UIImage imageNamed:@"Default-568h@2x.png"];
    
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    isLoaded = TRUE;
}


-(void)viewWillAppear:(BOOL)animated
{
    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    [navigationBar setBarTintColor:BLACK_COLOR];
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [navigationBar setTranslucent:NO];
    
    self.navigationController.navigationBarHidden=YES;
}


-(void)viewDidAppear:(BOOL)animated
{
    if (isLoaded) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSLog(@"defaults = %@", [defaults valueForKey:EMAIL_TEXT]);
        if([defaults objectForKey:EMAIL_TEXT]) {
            
            [self performSegueWithIdentifier:SEGUE_ID_FlagFromSplash sender:nil];
        }
    }
    isLoaded = FALSE;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Orientation Handling

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


#pragma mark - Facebook Login Management

- (IBAction)facebookLoginButtonTouched:(id)sender
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil) maskType:SVProgressHUDMaskTypeBlack];
//    [sender setUserInteractionEnabled:NO];
    // If the session state is any of the two "open" states when the button is clicked
    
    //to logout
//    if (FBSession.activeSession.state == FBSessionStateOpen
//        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
//        
//        // Close the session and remove the access token from the cache
//        // The session state handler (in the app delegate) will be called automatically
//        [FBSession.activeSession closeAndClearTokenInformation];
//        
//        // If the session state is not any of the two "open" states when the button is clicked
//    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
//             // Retrieve the app delegate
//             RCAppDelegate* appDelegate = (RCAppDelegate *)[UIApplication sharedApplication].delegate;
//             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
//             [appDelegate sessionStateChanged:session state:state error:error];
             NSLog(@"error = %@", error);
             if (error) {
                 [sender setUserInteractionEnabled:YES];
                 [SVProgressHUD dismiss];
             }else{
                 //request user info
                 [self requestUserInfo];
             }
             
         }];
//    }
}


// ------------> Code for requesting user information starts here <------------

/*
 This function asks for the user's public profile and birthday.
 It first checks for the existence of the public_profile and user_birthday permissions
 If the permissions are not present, it requests them
 If/once the permissions are present, it makes the user info request
 */
- (void)requestUserInfo
{
    // We will request the user's public picture and the user's birthday
    // These are the permissions we need:
//    NSArray *permissionsNeeded = @[@"public_profile"];
    
    // Request the permissions the user currently has
    [FBRequestConnection startWithGraphPath:@"/me/permissions"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error){
                                  [self makeRequestForUserData];
//                                  // These are the current permissions the user has
//                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
//                                  
//                                  // We will store here the missing permissions that we will have to request
//                                  NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
//                                  
//                                  // Check if all the permissions we need are present in the user's current permissions
//                                  // If they are not present add them to the permissions to be requested
//                                  for (NSString *permission in permissionsNeeded){
//                                      if (![currentPermissions objectForKey:permission]){
//                                          [requestPermissions addObject:permission];
//                                      }
//                                  }
//                                  
//                                  // If we have permissions to request
//                                  if ([requestPermissions count] > 0){
//                                      // Ask for the missing permissions
//                                      [FBSession.activeSession
//                                       requestNewReadPermissions:requestPermissions
//                                       completionHandler:^(FBSession *session, NSError *error) {
//                                           if (!error) {
//                                               // Permission granted, we can request the user information
//                                               [self makeRequestForUserData];
//                                           } else {
//                                               // An error occurred, we need to handle the error
//                                               // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
//                                               NSLog(@"error %@", error.description);
//                                           }
//                                       }];
//                                  } else {
//                                      // Permissions are present
//                                      // We can request the user information
//                                      [self makeRequestForUserData];
//                                  }
                                  
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                          }];
    
    
    
}

- (void) makeRequestForUserData
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // Success! Include your code to handle the results here
            NSLog(@"user info: %@", result);
            
            [self verifyFBLoginStatus:result];
        } else {
            // An error occurred, we need to handle the error
            // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
            NSLog(@"error %@", error.description);
        }
    }];
}


#pragma mark - Call Login API
- (void) verifyFBLoginStatus:(id<FBGraphUser>) user
{
    //assign user data to object
    _fbUserData = user;
    
    if ([RCSupport isNetworkAvaialble]) {
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:DEVICE_TOKEN];
        NSURL *url = [NSURL URLWithString:
                      [NSString stringWithFormat:@"%@?email=%@&password=%@&registrationid=%@&clientid=%@&clientsecret=%@&client=%@",
                       API_USER_LOGIN,
                       [NSString stringWithFormat:@"facebook%@", user[@"id"]],
                       user[@"id"],
                       deviceToken,
                       CLIENT_ID,
                       CLIENT_SECRET,
                       CLIENT_PLATFORM]];
        
        NSLog(@"URL : %@",url);
        ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
        [request setDelegate:self];
        [request setRequestMethod:@"GET"];
        [request startAsynchronous];
    }
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    //NSLog(@"Request finished");
    [SVProgressHUD dismiss];
    
    NSString *response = [request responseString];
    id respJSON = [response JSONValue];
    //NSLog(@"RESP : %@",respJSON);
    if ([respJSON isKindOfClass:[NSDictionary class]]) {
        NSString *result = [respJSON valueForKey:@"result"];
        int success = [[respJSON valueForKey:@"success"] integerValue];
        if (success) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setValue:result forKey:ACCESS_TOKEN];
            [defaults setValue:[NSString stringWithFormat:@"facebook%@", _fbUserData[@"id"]] forKey:EMAIL_TEXT];
            [defaults setValue:_fbUserData[@"id"] forKey:PASSWORD_TEXT];
            [defaults synchronize];
            
            [self performSegueWithIdentifier:SEGUE_ID_FlagFromSplash sender:self];
        }
        else {
            [self performSegueWithIdentifier:SEGUE_ID_FBSignUpFromSplash sender:self];
        }
    }
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    id respJSON = [response JSONValue];
    //NSLog(@"respJSON = %@", respJSON);

    //NSLog(@"Request Failed : %@",request.error);
    [SVProgressHUD dismiss];
    
    if (_fbUserData != nil) {
        [self performSegueWithIdentifier:SEGUE_ID_FBSignUpFromSplash sender:self];
    }
}


#pragma mark - Prepare for segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:SEGUE_ID_FBSignUpFromSplash]) {
        RCFacebookSignUpViewController *viewController = (RCFacebookSignUpViewController *) [segue destinationViewController];
        viewController.fbUserData = _fbUserData;
    }
}

@end