//
//  RCFacebookSignUpViewController.m
//  RaceControl
//
//  Created by Developer on 16/05/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import "RCFacebookSignUpViewController.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"


@interface RCFacebookSignUpViewController (){
    UITextField *activeField;
}

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)loginAction:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *fbUsernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *fbEmailTextField;
- (IBAction)fbDataVerifiedButtonTouched:(id)sender;

@end

@implementation RCFacebookSignUpViewController
@synthesize fbEmailTextField, fbUsernameTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    fbUsernameTextField.text = _fbUserData.name;
    fbEmailTextField.text = _fbUserData[@"email"];
}

- (void) viewWillAppear:(BOOL)animated{
    // show navigation bar
    self.navigationController.navigationBarHidden=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated{
    // hide navigation bar
    self.navigationController.navigationBarHidden = NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)fbDataVerifiedButtonTouched:(id)sender {
    if ([self checkSigninFields]) {
        if ([RCSupport isNetworkAvaialble]) {
            if ([activeField canResignFirstResponder]) {
                [activeField resignFirstResponder];
            }
            
        /*http://ragetankcispotter-jtzr2auyms.elasticbeanstalk.com/users?
			*Required Paramater("email") String Email,
			Paramater("facebooklogin") String facebooklogin,
			Paramater("facebookid") String facebookid,       (Example facebookid = "facebook123456789")
			*Required Paramater("username") String username,
			*Required Paramater("password") String Password, (Example facebookid = "123456789")
			Paramater("sex") String sex,
			Paramater("bio") String bio,
			Paramater("location") String location,
			Paramater("profilepic") String profilepic,
			Paramater("registrationid") String registrationid,
			*Required Paramater("clientid") String ClientID,
			*Required Paramater("clientsecret") String ClientSecret*/
            
//            userData = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:fbEmailTextField.text,
//                                                                                            fbUsernameTextField.text,
//                                                                                            _fbUserData[@"id"],
//                                                                                            _fbUserData[@"id"],
//                                                                                            [@"facebook" stringByAppendingString:_fbUserData[@"id"]], nil]
//                                                          forKeys:[NSArray arrayWithObjects:@"email",
//                                                                                            @"username",
//                                                                                            @"password",
//                                                                                            @"facebookid",
//                                                                                            @"facebooklogin",nil]];
//            [self performSegueWithIdentifier:SEGUE_ID_CarFromFBSignUp sender:self];
            
            
            [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil) maskType:SVProgressHUDMaskTypeBlack];
            
            NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:DEVICE_TOKEN];
            ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:API_USER_REGISTER]];
            [request setDelegate:self];
            [request setRequestMethod:@"POST"];
            [request setPostValue:fbEmailTextField.text forKey:@"email"];
            [request setPostValue:[@"facebook" stringByAppendingString:_fbUserData[@"id"]] forKey:@"facebooklogin"];
            [request setPostValue:_fbUserData[@"id"] forKey:@"facebookid"];
            [request setPostValue:fbUsernameTextField.text forKey:@"username"];
            [request setPostValue:_fbUserData[@"id"] forKey:@"password"];
            [request setPostValue:[RCSupport getUUID] forKey:@"id"];
            [request setPostValue:deviceToken forKey:@"registrationid"];
            [request setPostValue:CLIENT_ID forKey:@"clientid"];
            [request setPostValue:CLIENT_SECRET forKey:@"clientsecret"];
            [request setPostValue:CLIENT_PLATFORM forKey:@"client"];
            [request startAsynchronous];
        }
    }
}
//
//- (IBAction)registerAction:(id)sender
//{
//    if ([self checkRegisterFields])
//    {
//        if ([RCSupport isNetworkAvaialble])
//        {
//            if ([activeField canResignFirstResponder]) {
//                [activeField resignFirstResponder];
//            }
//            [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil) maskType:SVProgressHUDMaskTypeBlack];
//            
//            NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:DEVICE_TOKEN];
//            ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:API_USER_REGISTER]];
//            [request setDelegate:self];
//            [request setRequestMethod:@"POST"];
//            [request setPostValue:txtEmail.text forKey:@"email"];
//            [request setPostValue:txtUserName.text forKey:@"username"];
//            [request setPostValue:txtPassword.text forKey:@"password"];
//            [request setPostValue:[RCSupport getUUID] forKey:@"id"];
//            [request setPostValue:deviceToken forKey:@"registrationid"];
//            [request setPostValue:CLIENT_ID forKey:@"clientid"];
//            [request setPostValue:CLIENT_SECRET forKey:@"clientsecret"];
//            [request setPostValue:CLIENT_PLATFORM forKey:@"client"];
//            [request startAsynchronous];
//        }
//    }
//}


-(BOOL)checkSigninFields {
	if ([fbEmailTextField.text length] == 0) {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_EMAIL",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
		[alertView show];
        [fbEmailTextField becomeFirstResponder];
		return FALSE;
	}
    else {
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", EMAIL_REGEX];
        
        if ([emailTest evaluateWithObject:fbEmailTextField.text] == FALSE) {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"WRONG_EMAIL",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
            [alertView show];
            [fbEmailTextField becomeFirstResponder];
            return FALSE;
        }
    }
	return TRUE;
}

- (IBAction)loginAction:(id)sender {
}

- (void)requestFinished:(ASIHTTPRequest *)request {
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

            [self performSegueWithIdentifier:SEGUE_ID_FLAG_FROM_FBSignUp sender:self];
        }
        else
        {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:result delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
            [alertView show];
        }
    }
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"request = %@", [request.error localizedDescription]);
    
    [SVProgressHUD dismiss];
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


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField=textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField=nil;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == fbEmailTextField)
    {
        [fbEmailTextField becomeFirstResponder];
    }
    else if (textField == fbUsernameTextField)
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

#pragma mark - Prepare for segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:SEGUE_ID_CarFromFBSignUp]) {
        RCCarTableViewController *viewController = (RCCarTableViewController *) [segue destinationViewController];
        viewController.userData = userData;
    }
}


@end
