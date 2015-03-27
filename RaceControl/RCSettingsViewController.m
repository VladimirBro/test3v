//
//  RCSettingsViewController.m
//  RaceControl
//
//  Created by Technologies33 on 07/08/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import "RCSettingsViewController.h"

@interface RCSettingsViewController ()
- (IBAction)inviteViaEmailButtonTouched:(id)sender;
- (IBAction)inviteViaTextButtonTouched:(id)sender;
- (IBAction)facebookInviteButtonTouched:(id)sender;
@end

@implementation RCSettingsViewController
@synthesize homeViewController;
@synthesize lblCarNo;
@synthesize lblEmail;
@synthesize logoutBtn;

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
    logoutBtn.layer.cornerRadius = 5.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    RCAppDelegate *appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
   
    if (appDelegate.userDictionary) {
        if ([appDelegate.userDictionary objectForKey:@"carnumber"]) {
            self.lblCarNo.text = [NSString stringWithFormat:@"%@    >",[appDelegate.userDictionary objectForKey:@"carnumber"]];
        }
        if ([appDelegate.userDictionary objectForKey:@"email"])
        {
            self.lblEmail.text = [NSString stringWithFormat:@" %@",[appDelegate.userDictionary objectForKey:@"email"]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

//IBActions
- (IBAction)inviteViaEmailButtonTouched:(id)sender {
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc]init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:@"Spotter"];
    [mailComposer setMessageBody:@"Cool app to spot." isHTML:NO];
    [self presentViewController:mailComposer animated:YES completion:nil];
}

- (IBAction)inviteViaTextButtonTouched:(id)sender {
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setBody:@"Cool app to spot."];
    
    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}

- (IBAction)facebookInviteButtonTouched:(id)sender {
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

#pragma mak - Mail Composer Delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *) error{
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

#pragma mak - Message Composer Delegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
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


#pragma mark - Facebook Dialogue API
- (void)webDialogsWillPresentDialog:(NSString *)dialog
                         parameters:(NSMutableDictionary *)parameters
                            session:(FBSession *)session{
    
}

- (BOOL)webDialogsDialog:(NSString *)dialog
              parameters:(NSDictionary *)parameters
                 session:(FBSession *)session
     shouldAutoHandleURL:(NSURL *)url{
    return YES;
    
}

- (void)webDialogsWillDismissDialog:(NSString *)dialog
                         parameters:(NSDictionary *)parameters
                            session:(FBSession *)session
                             result:(FBWebDialogResult *)result
                                url:(NSURL **)url
                              error:(NSError **)error{
    
}


-(IBAction)logout:(id)sender
{
    [homeViewController logout:nil];
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

-(IBAction)editCarNo:(id)sender
{
    [self performSegueWithIdentifier:SEGUE_ID_CarFromSettings sender:self];
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:SEGUE_ID_CarFromSettings]) {
        RCCarTableViewController *destinationViewController = (RCCarTableViewController*)[segue destinationViewController];
        destinationViewController.isFromSettings =  TRUE;
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


@end
