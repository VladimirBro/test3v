//
//  RCCarViewController.m
//  RaceControl
//
//  Created by Technologies33 on 07/08/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import "RCCarTableViewController.h"
#import "RCHomeViewController.h"


@interface RCCarTableViewController ()
{
    NSInteger numberOfSection;
}

@property (strong, nonatomic) IBOutlet UIButton *saftyVehicalButton;

- (IBAction)saftyVehicalButtonTouched:(id)sender;

@end


@implementation RCCarTableViewController
@synthesize userData;
@synthesize isFromSettings;
@synthesize homeViewController;


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
    
    numberOfSection = 2;
    
    [btnDone setTitleColor:YELLOW_COLOR forState:UIControlStateNormal];
    [btnDone setTitleColor:YELLOW_COLOR forState:UIControlStateHighlighted];
    btnDone.layer.cornerRadius = 5.0;
    btnDone.clipsToBounds = YES;
    
    if (self.isFromSettings) {
        RCAppDelegate *appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];

        NSString *string = [appDelegate.userDictionary objectForKey:@"carnumber"];
        if (string) txtCarNo.text = string;

        string = [appDelegate.userDictionary objectForKey:@"carclass"];
        if (string) txtCarClass.text = string;

        string = [appDelegate.userDictionary objectForKey:@"transpondernumber"];
        if (string) txtTransponderNumber.text = string;
        
        if ([txtCarClass.text length] || [txtTransponderNumber.text length]) [self saftyVehicalButtonTouched:_saftyVehicalButton];

    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (IBAction)hideKeyboard:(id)sender
{
    if ([txtCarNo canResignFirstResponder])
    {
        [txtCarNo resignFirstResponder];
    }
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField canResignFirstResponder])
    {
        [textField resignFirstResponder];
        //[self performSelector:@selector(registerAction:) withObject:nil afterDelay:0.3f];
    }
    return YES;
}


-(BOOL)checkCarFields
{
	if ([txtCarNo.text length] == 0) {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"NO_CAR_NO",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
		[alertView show];
        [txtCarNo becomeFirstResponder];
		return FALSE;
	}else if ([_saftyVehicalButton isSelected] && [txtCarClass.text length] == 0) {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Enter Car Class.",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
		[alertView show];
        [txtCarClass becomeFirstResponder];
		return FALSE;
	} else if ([_saftyVehicalButton isSelected] && [txtTransponderNumber.text length] == 0) {
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Enter Transporter Number.",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil];
		[alertView show];
        [txtTransponderNumber becomeFirstResponder];
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
        int success = [[respJSON valueForKey:@"success"] intValue];
        if (success) {
//            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//            [defaults setValue:result forKey:ACCESS_TOKEN];
//            [defaults synchronize];
            if (self.isFromSettings) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [self performSegueWithIdentifier:SEGUE_ID_FlagFromCar sender:self];
            }
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


- (IBAction)doneAction:(id)sender
{
    if ([self checkCarFields])
    {
        RCAppDelegate *appDelegate = (RCAppDelegate*)[[UIApplication sharedApplication] delegate];
        [appDelegate.userDictionary setObject:txtCarNo.text forKey:@"carnumber"];
        [appDelegate.userDictionary setObject:txtCarClass.text forKey:@"carclass"];
        [appDelegate.userDictionary setObject:txtTransponderNumber.text forKey:@"transpondernumber"];
        
        if ([RCSupport isNetworkAvaialble]) {
            if ([txtCarNo canResignFirstResponder]) {
                [txtCarNo resignFirstResponder];
            }
            [SVProgressHUD showWithStatus:NSLocalizedString(@"PLEASE_WAIT", nil) maskType:SVProgressHUDMaskTypeBlack];
            
            NSString *deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:DEVICE_TOKEN];
            NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:PASSWORD_TEXT];
            ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:API_USER_REGISTER]];
            [request setDelegate:self];
            [request setRequestMethod:@"POST"];
            
            if (appDelegate.userDictionary) {
                [request setPostValue:[appDelegate.userDictionary objectForKey:@"email"] forKey:@"email"];
                [request setPostValue:[appDelegate.userDictionary objectForKey:@"username"] forKey:@"username"];
                [request setPostValue:password forKey:@"password"];
                if ([appDelegate.userDictionary objectForKey:@"facebooklogin"]) {
                    [request setPostValue:[appDelegate.userDictionary objectForKey:@"facebooklogin"] forKey:@"facebooklogin"];
                    [request setPostValue:[appDelegate.userDictionary objectForKey:@"facebookid"] forKey:@"facebookid"];
                }
                [request setPostValue:[appDelegate.userDictionary objectForKey:@"id"] forKey:@"id"];
            }
            
            [request setPostValue:txtCarNo.text forKey:@"carnumber"];
            [request setPostValue:txtCarClass.text forKey:@"class"];
            [request setPostValue:txtTransponderNumber.text forKey:@"transpondernumber"];
            
            [request setPostValue:deviceToken forKey:@"registrationid"];
            [request setPostValue:CLIENT_ID forKey:@"clientid"];
            [request setPostValue:CLIENT_SECRET forKey:@"clientsecret"];
            [request setPostValue:CLIENT_PLATFORM forKey:@"client"];
            [request startAsynchronous];
        }
    }
}


// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:SEGUE_ID_FlagFromCar]) {
        RCFlagViewController *destinationViewController = (RCFlagViewController*)[segue destinationViewController];
        destinationViewController.currentFlags = self.homeViewController.currentFlags;
        destinationViewController.eventId = self.homeViewController.eventId;
        destinationViewController.trackId = self.homeViewController.trackId;
        destinationViewController.homeViewController = self.homeViewController;
    }
}


#pragma mark - TableView Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return numberOfSection;
}


- (IBAction)saftyVehicalButtonTouched:(id)sender {
    UIButton *button = (UIButton *) sender;
    [button setSelected:![button isSelected]];
    
    if ([button isSelected])
        numberOfSection = 3;
    else
        numberOfSection = 2;
 
    /* Animate the table view reload */
    [UIView transitionWithView:self.tableView
                      duration: 0.35f
                       options: UIViewAnimationOptionTransitionCrossDissolve
                    animations: ^(void){
         [self.tableView reloadData];
     }completion: ^(BOOL isFinished){
         /* TODO: Whatever you want here */
     }];
}

@end
