//
//  RCSignUpViewController.m
//  RaceControl
//
//  Created by Jack on 4/8/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import "RCSignUpViewController.h"

@interface RCSignUpViewController ()

@end

@implementation RCSignUpViewController

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
    [scrollView setContentSize:CGSizeMake(320, 504)];
    
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    // hide navigation bar
    self.navigationController.navigationBarHidden=NO;
    
    [registerBtn setTitleColor:YELLOW_COLOR forState:UIControlStateNormal];
    [registerBtn setTitleColor:YELLOW_COLOR forState:UIControlStateHighlighted];
    //registerBtn.backgroundColor = BLACK_COLOR;
    
    //registerBtn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    //registerBtn.layer.borderWidth = 2.0f;
    registerBtn.layer.cornerRadius = 5.0;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self registerForKeyboardNotifications];
    activeField=textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self unregisterForKeyboardNotifications];
    activeField=nil;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == txtEmail)
    {
        [txtUserName becomeFirstResponder];
    }
    else if (textField == txtUserName)
    {
        [txtPassword becomeFirstResponder];
    }
    else if (textField == txtPassword)
    {
        [txtConfirmPassword becomeFirstResponder];
    }
    else if (textField == txtConfirmPassword)
    {
        if ([activeField canResignFirstResponder])
        {
            [activeField resignFirstResponder];
            [self performSelector:@selector(registerAction:) withObject:nil afterDelay:0.3f];
        }
    }
    return YES;
}


- (IBAction)hideKeyboard:(id)sender
{
    if ([activeField canResignFirstResponder])
    {
        [activeField resignFirstResponder];
    }
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)name:UIKeyboardWillHideNotification object:nil];
}


-(void)unregisterForKeyboardNotifications
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    CGRect aRect = self.view.frame;
    //NSLog(@"aRect : %@", NSStringFromCGRect(aRect));
    aRect.size.height -= kbSize.height+54;
    
   // NSLog(@"ORIGIN : %@", NSStringFromCGPoint(activeField.frame.origin));
    CGRect _rect = activeField.frame;
    _rect.origin.y += 64;
    
    //NSLog(@"ORIGIN : %@", NSStringFromCGPoint(activeField.frame.origin));
   // NSLog(@"aRect : %@", NSStringFromCGRect(aRect));
    if (!CGRectContainsPoint(aRect, _rect.origin))
    {
	    CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height+54);
        //NSLog(@"ORIGIN : %@",NSStringFromCGPoint(scrollPoint));
		[scrollView setContentOffset:scrollPoint animated:YES];
    }
    
    
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}



-(BOOL)checkRegisterFields
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
	
    if ([txtUserName.text length] == 0) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_USER_NAME",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alertView show];
        [txtUserName becomeFirstResponder];
        return FALSE;
    }
    if ([txtPassword.text length] == 0) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_PASS",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alertView show];
        [txtPassword becomeFirstResponder];
        return FALSE;
    }
    if ([txtConfirmPassword.text length] == 0) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_RE_PASS",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alertView show];
        [txtConfirmPassword becomeFirstResponder];
        return FALSE;
    }
    else if (![txtPassword.text isEqualToString:txtConfirmPassword.text]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_PASS_MATCH",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
        [alertView show];
        [txtConfirmPassword becomeFirstResponder];
        return FALSE;
    }
	return TRUE;
}


- (void)requestFinished:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
    
    NSString *response = [request responseString];
    id respJSON = [response JSONValue];
    //NSLog(@"RESP : %@",respJSON);
    if ([respJSON isKindOfClass:[NSDictionary class]]) {
        NSString *result = [respJSON valueForKey:@"result"];
        int success = [[respJSON valueForKey:@"success"] integerValue];
        if (success) {
            [[NSUserDefaults standardUserDefaults] setValue:result forKey:ACCESS_TOKEN];
            [self performSegueWithIdentifier:SEGUE_ID_FLAG_FROM_REGISTER sender:self];
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
    [SVProgressHUD dismiss];
}


- (IBAction)registerAction:(id)sender
{
    if ([self checkRegisterFields])
    {
        if ([RCSupport isNetworkAvaialble])
        {
            if ([activeField canResignFirstResponder]) {
                [activeField resignFirstResponder];
            }
            
//            userData = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:txtEmail.text,txtUserName.text,txtPassword.text, nil] forKeys:[NSArray arrayWithObjects:@"email",@"username",@"password",nil]];
//            [self performSegueWithIdentifier:SEGUE_ID_CarFromSignUp sender:self];
            
            [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil) maskType:SVProgressHUDMaskTypeBlack];
            
            NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:DEVICE_TOKEN];
            ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:API_USER_REGISTER]];
            [request setDelegate:self];
            [request setRequestMethod:@"POST"];
            [request setPostValue:txtEmail.text forKey:@"email"];
            [request setPostValue:txtUserName.text forKey:@"username"];
            [request setPostValue:txtPassword.text forKey:@"password"];
            [request setPostValue:[RCSupport getUUID] forKey:@"id"];
            [request setPostValue:deviceToken forKey:@"registrationid"];
            [request setPostValue:CLIENT_ID forKey:@"clientid"];
            [request setPostValue:CLIENT_SECRET forKey:@"clientsecret"];
            [request setPostValue:CLIENT_PLATFORM forKey:@"client"];
            [request startAsynchronous];
            
        }
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

#pragma mark - Prepare for segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([[segue identifier] isEqualToString:SEGUE_ID_CarFromSignUp]) {
        RCCarTableViewController *viewController = (RCCarTableViewController *) [segue destinationViewController];
        viewController.userData = userData;
    }
}

@end
