//
//  RCViewController.m
//  RaceControl
//
//  Created by Jack on 4/8/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import "RCViewController.h"
#import "RCFacebookSignUpViewController.h"

@interface RCViewController ()
@property (nonatomic, strong) id <FBGraphUser> fbUserData;
@end

@implementation RCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    
    //txtEmail.text = @"tech1@test.com";
    //txtPassword.text=@"123";
    
    //    // Create a FBLoginView to log the user in with basic, email and friend list permissions
    //    // You should ALWAYS ask for basic permissions (public_profile) when logging the user in
    //    FBLoginView *loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"public_profile", @"email", @"user_friends"]];
    //
    //    // Set this loginUIViewController to be the loginView button's delegate
    //    loginView.delegate = self;
    //    loginView.tooltipColorStyle = FBTooltipColorStyleNeutralGray;
    //
    //    // Align the button in the center horizontally
    //    loginView.frame = CGRectOffset(loginView.frame,
    //                                   (self.view.center.x - (loginView.frame.size.width / 2)),
    //                                   5);
    //
    //    // Align the button in the center vertically
    //    loginView.center = CGPointMake(self.view.center.x, self.view.frame.size.height - (loginView.frame.size.height + self.navigationController.navigationBar.frame.size.height));
    //
    //
    //    // Add the button to the view
    //    [self.view addSubview:loginView];
}

-(void)viewWillAppear:(BOOL)animated
{
    UINavigationBar* navigationBar = self.navigationController.navigationBar;
    [navigationBar setBarTintColor:BLACK_COLOR];
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    navigationBar.topItem.title = @"Login";
    [navigationBar setTranslucent:NO];
    
    // show navigation bar
    self.navigationController.navigationBarHidden=NO;
    
    [loginBtn setTitleColor:YELLOW_COLOR forState:UIControlStateNormal];
    [loginBtn setTitleColor:YELLOW_COLOR forState:UIControlStateHighlighted];
    //loginBtn.backgroundColor = BLACK_COLOR;
    
    //loginBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    //loginBtn.layer.borderWidth = 2.0f;
    loginBtn.layer.cornerRadius = 5.0;
    
    /*
     [registerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
     registerBtn.backgroundColor = yellowColor;
     
     registerBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
     registerBtn.layer.borderWidth = 2.0f;
     registerBtn.layer.cornerRadius = 5.0;
     */
}

-(void)viewDidAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if([defaults objectForKey:EMAIL_TEXT]) {
        // hide navigation bar
        self.navigationController.navigationBarHidden=YES;
        splashImageView.hidden = false;
        if([UIScreen mainScreen].bounds.size.height > 500)
            splashImageView.image = [UIImage imageNamed:@"Default-568h@2x.png"];
        else
            splashImageView.image = [UIImage imageNamed:@"Default.png"];
        
        txtEmail.text = [defaults valueForKey:EMAIL_TEXT];
        txtPassword.text = [defaults valueForKey:PASSWORD_TEXT];
        [self performSelector:@selector(loginAction:) withObject:nil];
    }
    else {
        splashImageView.hidden = true;
    }
}

#pragma mark - Facebook Login Management
- (IBAction)facebookLoginButtonTouched:(id)sender {
    [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil) maskType:SVProgressHUDMaskTypeBlack];
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         NSLog(@"error = %@", error);
         if (error) {
             [sender setUserInteractionEnabled:YES];
             [SVProgressHUD dismiss];
         }else{
             [self requestUserInfo];
         }
         
     }];
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
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                          }];
    
    
    
}

- (void) makeRequestForUserData {
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
- (void) verifyFBLoginStatus:(id<FBGraphUser>) user {
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
        request.tag = ASIHttpRequestTagFBLogin;
        [request setDelegate:self];
        [request setRequestMethod:@"GET"];
        [request startAsynchronous];
    }
}

#pragma mark - Prepare for segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:SEGUE_ID_FBSignUpFromLogin]) {
        RCFacebookSignUpViewController *viewController = (RCFacebookSignUpViewController *) [segue destinationViewController];
        viewController.fbUserData = _fbUserData;
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField=textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField=nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtEmail)
    {
        [txtPassword becomeFirstResponder];
    }
    else if (textField == txtPassword)
    {
        if ([activeField canResignFirstResponder])
        {
            [activeField resignFirstResponder];
            [self performSelector:@selector(loginAction:) withObject:nil afterDelay:0.3f];
        }
    }
    return YES;
}

/*
 - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
 {
 NSUInteger newLength = [textField.text length] + [string length] - range.length;
 return (newLength > TEXT_LIMIT) ? NO : YES;
 }
 */

- (IBAction)hideKeyboard:(id)sender
{
    if ([activeField canResignFirstResponder])
    {
        [activeField resignFirstResponder];
    }
}

-(BOOL)checkSigninFields
{
	if ([txtEmail.text length] == 0) {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_EMAIL",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
		[alertView show];
        [txtEmail becomeFirstResponder];
		return FALSE;
	}
    else
    {
        
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", EMAIL_REGEX];
        if ([emailTest evaluateWithObject:txtEmail.text] == FALSE)
        {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"WRONG_EMAIL",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
            [alertView show];
            [txtEmail becomeFirstResponder];
            return FALSE;
        }
    }
	
    if ([txtPassword.text length] == 0) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_PASS",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alertView show];
        [txtPassword becomeFirstResponder];
        return FALSE;
    }
	return TRUE;
}

- (IBAction)loginAction:(id)sender
{
    if ([self checkSigninFields])
    {
        if ([RCSupport isNetworkAvaialble])
        {
            
            if ([activeField canResignFirstResponder]) {
                [activeField resignFirstResponder];
            }
            
            [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil) maskType:SVProgressHUDMaskTypeBlack];
            NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:DEVICE_TOKEN];
            NSURL *url = [NSURL URLWithString:
                          [[NSString stringWithFormat:@"%@?email=%@&password=%@&registrationid=%@&clientid=%@&clientsecret=%@&client=%@",
                            API_USER_LOGIN,
                            txtEmail.text,
                            txtPassword.text,
                            deviceToken,
                            CLIENT_ID,
                            CLIENT_SECRET,
                            CLIENT_PLATFORM] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSLog(@"URL from LOGIN: %@",url);
            ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
            request.tag = ASIHttpRequestTagLogin;
            [request setDelegate:self];
            [request setRequestMethod:@"GET"];
            [request startAsynchronous];
        }
    }
}

#pragma mark - ASIHTTPRequest Delegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
    
    switch (request.tag) {
        case ASIHttpRequestTagFBLogin:{
            NSString *response = [request responseString];
            id respJSON = [response JSONValue];
            NSLog(@"RESP FROM LOGIN: %@",respJSON);
            if ([respJSON isKindOfClass:[NSDictionary class]]) {
                NSString *result = [respJSON valueForKey:@"result"];
                int success = [[respJSON valueForKey:@"success"] integerValue];
                if (success) {
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setValue:result forKey:ACCESS_TOKEN];
                    [defaults setValue:[NSString stringWithFormat:@"facebook%@", _fbUserData[@"id"]] forKey:EMAIL_TEXT];
                    [defaults setValue:_fbUserData[@"id"] forKey:PASSWORD_TEXT];
                    [defaults synchronize];
                    
                    [self performSegueWithIdentifier:SEGUE_ID_FLAG_FROM_LOGIN sender:self];
                }
                else
                {
                    [self performSegueWithIdentifier:SEGUE_ID_FBSignUpFromLogin sender:self];
                }
            }
        }
            break;
            
        default:{
            NSString *response = [request responseString];
            id respJSON = [response JSONValue];
            //NSLog(@"RESP : %@",respJSON);
            if ([respJSON isKindOfClass:[NSDictionary class]]) {
                NSString *result = [respJSON valueForKey:@"result"];
                int success = [[respJSON valueForKey:@"success"] integerValue];
                if (success) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    
                    [defaults setValue:result forKey:ACCESS_TOKEN];
                    [defaults setValue:txtEmail.text forKey:EMAIL_TEXT];
                    [defaults setValue:txtPassword.text forKey:PASSWORD_TEXT];
                    [defaults synchronize];
                    
                    txtEmail.text = @"";
                    txtPassword.text = @"";
                    
                    [self performSegueWithIdentifier:SEGUE_ID_FLAG_FROM_LOGIN sender:self];
                }
                else {
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:result delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
                    [alertView show];
                }
            }
        }
            break;
    }
    //NSLog(@"Request finished");
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"Request Failed : %@",request.error);
    [SVProgressHUD dismiss];
    if (!splashImageView.hidden) {
        splashImageView.hidden = true;
        txtEmail.text = @"";
        txtPassword.text = @"";
        self.navigationController.navigationBarHidden=NO;
        //[self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end