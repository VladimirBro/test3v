//
//  RCSettingsCustomVC.m
//  RaceControl
//
//  Created by Vitaliy on 25.03.15.
//  Copyright (c) 2015 Technologies33. All rights reserved.
//

#import "RCSettingsCustomVC.h"
#import "ASIFormDataRequest.h"
#import "JSON.h"

@class RCDraw2D;

@interface RCSettingsCustomVC () <ASIHTTPRequestDelegate>
{
    __weak IBOutlet UIView  *viewForData;
    __weak IBOutlet UILabel *subTitle;
    __weak IBOutlet UITextField *carNumberTextField;
    __weak IBOutlet UITextField *classTextField;
    __weak IBOutlet UITextField *transTextField;
    NSArray *textFieldArray;
    UITextField *activeField;
}

- (IBAction)facebookBtnPressed:(id)sender;
- (IBAction)mailBtnPressed:(id)sender;
- (IBAction)messageBtnPressed:(id)sender;

@end


@implementation RCSettingsCustomVC
@synthesize homeViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initInterface];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)initInterface
{
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    subTitle.text = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] valueForKey:EMAIL_TEXT]];
    _logoutBtn.layer.cornerRadius = 5.0;
    _logoutBtn.clipsToBounds = YES;
    
    viewForData.layer.cornerRadius = 5.0f;
    viewForData.layer.borderWidth = 1.0;
    viewForData.layer.borderColor = grayColor;
    viewForData.clipsToBounds = YES;
    
    [self setDisableTextField];
    
    textFieldArray = @[carNumberTextField, classTextField, transTextField];
    
    RCAppDelegate *appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *string = [appDelegate.userDictionary objectForKey:@"carnumber"];
    if (string) carNumberTextField.text = string;
    
    string = [appDelegate.userDictionary objectForKey:@"carclass"];
    if (string) classTextField.text = string;
    
    string = [appDelegate.userDictionary objectForKey:@"transpondernumber"];
    if (string) transTextField.text = string;
}


- (void)setEnableTextField
{
    [carNumberTextField setEnabled:YES];
    [carNumberTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [classTextField setEnabled:YES];
    [classTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [transTextField setEnabled:YES];
    [transTextField setBorderStyle:UITextBorderStyleRoundedRect];
}


- (void)setDisableTextField
{
    [carNumberTextField setEnabled:NO];
    [carNumberTextField setBorderStyle:UITextBorderStyleNone];
    [classTextField setEnabled:NO];
    [classTextField setBorderStyle:UITextBorderStyleNone];
    [transTextField setEnabled:NO];
    [transTextField setBorderStyle:UITextBorderStyleNone];
}


#pragma mark -

- (BOOL)checkCarTextFields
{
    if (carNumberTextField.text.length == 0) {
        [carNumberTextField becomeFirstResponder];
        return NO;
    } else if (classTextField.text.length == 0) {
        [classTextField becomeFirstResponder];
        return NO;
    } else if (transTextField.text.length == 0) {
        [transTextField becomeFirstResponder];
        return NO;
    } else
        return YES;
}


- (void)saveCarData
{
    if ([RCSupport isNetworkAvaialble]) {
        [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil) maskType:SVProgressHUDMaskTypeBlack];
        
        NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:DEVICE_TOKEN];
        NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:PASSWORD_TEXT];
        ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:API_USER_REGISTER]];
        [request setDelegate:self];
        [request setRequestMethod:@"POST"];
        
        [request setPostValue:carNumberTextField.text forKey:@"carnumber"];
        [request setPostValue:classTextField.text forKey:@"class"];
        [request setPostValue:transTextField.text forKey:@"transpondernumber"];
        [request setPostValue:password forKey:@"password"];
        
        [request setPostValue:deviceToken forKey:@"registrationid"];
        [request setPostValue:CLIENT_ID forKey:@"clientid"];
        [request setPostValue:CLIENT_SECRET forKey:@"clientsecret"];
        [request setPostValue:CLIENT_PLATFORM forKey:@"client"];
        
        [request startAsynchronous];
    }
}


#pragma mark - ASIHTTPRequestDelegate

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
    NSString *response = [request responseString];
    id respJSON = [response JSONValue];
    NSLog(@"RESP SettingsVC: %@",respJSON);
    if ([respJSON isKindOfClass:[NSDictionary class]]) {
        NSString *result = [respJSON valueForKey:@"result"];
        int success = [[respJSON valueForKey:@"success"] intValue];
        if (success) {
            //            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            //            [defaults setValue:result forKey:ACCESS_TOKEN];
            //            [defaults synchronize];
//            if (self.isFromSettings) {
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//            else
//            {
//                [self performSegueWithIdentifier:SEGUE_ID_FlagFromCar sender:self];
//            }
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


#pragma mark - UITextFields Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self stepNextField:textField];
    return YES;
}


- (void)stepNextField:(UITextField*)textField
{
    NSInteger index = [textFieldArray indexOfObject:textField];
    if (index != textFieldArray.count - 1) {
        UITextField *nextTextField = (UITextField*)[textFieldArray objectAtIndex:index + 1];
        [nextTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self performSelector:@selector(saveCarData) withObject:nil afterDelay:0.3f];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == transTextField) {
        NSCharacterSet *myCharSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
        for (int i = 0; i < [string length]; i++) {
            unichar c = [string characterAtIndex:i];
            if ([myCharSet characterIsMember:c]) {
                NSUInteger nl = textField.text.length + string.length - range.length;
                return (nl > 7) ? NO : YES;
            }
        }
        return NO;
    } else
        return YES;
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Message Composer Delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            [controller dismissViewControllerAnimated:YES completion:nil];
            break;
        case MessageComposeResultSent:
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success!", nil) message:NSLocalizedString(@"Invite sent successfully!", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
            
            break;
        case MessageComposeResultFailed:
            
            break;
            
        default:
            break;
    }
}


#pragma mark - Mail Composer Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *) error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            [controller dismissViewControllerAnimated:YES completion:nil];
            break;
            
        case MFMailComposeResultSaved:
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success!", nil) message:NSLocalizedString(@"Invite saved successfully.", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
            break;
            
        case MFMailComposeResultSent:
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Success!", nil) message:NSLocalizedString(@"Invite sent successfully.", nil) delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil]show];
            break;
            
        case MFMailComposeResultFailed:
            
            break;
            
        default:
            break;
    }
}


#pragma mark - Handler Actions

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:YES];
    if (editing == YES) {
        [self setEnableTextField];
        [carNumberTextField becomeFirstResponder];
    } else {
        if ([self checkCarTextFields]) {
            [self setDisableTextField];
            [self saveCarData];
        } else {
            [super setEditing:YES animated:YES];
        }
    }
}


- (IBAction)logoutBtnPressed:(id)sender
{
    [homeViewController logout:nil];
    
    if (FBSession.activeSession.state == FBSessionStateOpen ||
        FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
    
    if ([RCSupport isNetworkAvaialble])
    {
        NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:ACCESS_TOKEN];
        accessToken = [accessToken stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        //NSLog(@"accessToken : %@",accessToken);
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?access_token=%@",
                                           API_USER_LOGOUT,
                                           accessToken]];
        //NSLog(@"URL : %@",[url absoluteString]);
        ASIFormDataRequest *logoutRequest=[ASIFormDataRequest requestWithURL:url];
        [logoutRequest setDelegate:nil];
        [logoutRequest setRequestMethod:@"DELETE"];
        [logoutRequest startAsynchronous];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:EMAIL_TEXT];
    [defaults removeObjectForKey:PASSWORD_TEXT];
    [defaults synchronize];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


- (IBAction)facebookBtnPressed:(id)sender
{
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:[FBSession activeSession]
     message:@"YOUR_MESSAGE_HERE"
     title:nil
     parameters:nil
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or sending the request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 //                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 //                 if (![urlParams valueForKey:@"request"]) {
                 //                     // User clicked the Cancel button
                 //                     NSLog(@"User canceled request.");
                 //                 } else {
                 //                     // User clicked the Send button
                 //                     NSString *requestID = [urlParams valueForKey:@"request"];
                 //                     NSLog(@"Request ID: %@", requestID);
                 //                 }
             }
         }
     }];
}


- (IBAction)mailBtnPressed:(id)sender
{
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc]init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:@"Spotter"];
    [mailComposer setMessageBody:@"Cool app to spot." isHTML:NO];
    [self presentViewController:mailComposer animated:YES completion:nil];
}


- (IBAction)messageBtnPressed:(id)sender
{
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setBody:@"Cool app to spot."];
    
    [self presentViewController:messageController animated:YES completion:nil];
}


- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
