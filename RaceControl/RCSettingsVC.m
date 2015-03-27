//
//  RCSettingsVC.m
//  RaceControl
//
//  Created by Vitaliy on 24.03.15.
//  Copyright (c) 2015 Technologies33. All rights reserved.
//

#import "RCSettingsVC.h"
#import "CustomHeaderCell.h"
#import "CustomCell.h"


@interface RCSettingsVC ()

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@property (weak, nonatomic) IBOutlet UINavigationItem *editBtn;

- (IBAction)logoutBtnPressed:(id)sender;
//- (IBAction)editBtnPressed:(id)sender;

@end



@implementation RCSettingsVC


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    _logoutBtn.layer.cornerRadius = 5.0;
    _logoutBtn.clipsToBounds = YES;
    
    NSArray *s1 = [NSArray arrayWithObjects:@"Car number", @"Class", @"Trans #", nil];
    NSArray *s2 = [NSArray arrayWithObjects:@"Facebook", @"Email", @"Message", nil];
    nameRows = [[NSMutableArray alloc] initWithObjects:s1, s2, nil];
    
    
    
    myTableView.delegate = self;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [myTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - TableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return nameRows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSString *str = [[NSString alloc] init];
    if(section == 0)
        str =  @"  Logged in as:";
    
    if(section == 1)
        str =  @"  Invite users by:";
    
    return @""  ;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CustomHeaderCell* headerCell = [myTableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    
    if (section == 0) {
        headerCell.title.text = @"Logged in as:";
        headerCell.subtitle.text = [NSString stringWithFormat:@" %@", [[NSUserDefaults standardUserDefaults] valueForKey:EMAIL_TEXT]];
    } else if (section == 1) {
        headerCell.subtitle.text = nil;
        headerCell.title.text = @"Invite users by:";
    }
    [headerCell.title sizeToFit];
    
    return headerCell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[nameRows objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCell *cellCustom = [myTableView dequeueReusableCellWithIdentifier:@"customCell"];
    
    cellCustom.title.text = [[nameRows objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (indexPath.section == 1) {
        cellCustom.subtitle.text = @"";
    }
    
    
    if ([cellCustom respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cellCustom setPreservesSuperviewLayoutMargins:NO];
    }
    
    return cellCustom;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"IndexPath Section: %ld, Row: %ld", (long)indexPath.section, (long)indexPath.row);
    if ((indexPath.section == 0) && (indexPath.row == 0)) {
        UIStoryboard *sb = DELEGATE.window.rootViewController.storyboard;
        id vc = [sb instantiateViewControllerWithIdentifier:@"CarTableVC"];
        [self.navigationController pushViewController:vc animated:YES];
    } else if ((indexPath.section == 0) && (indexPath.row == 1)) {
        
    } else if ((indexPath.section == 0) && (indexPath.row == 2)) {
        
    } else if ((indexPath.section == 1) && (indexPath.row == 0)) {
        // FaceBook
        
    } else if ((indexPath.section == 1) && (indexPath.row == 1))
        [self showMailVC];
    
    else if ((indexPath.section == 1) && (indexPath.row == 2))
        [self showMessageVC];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


#pragma mark

- (void)showMailVC
{
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc]init];
    mailComposer.mailComposeDelegate = self;
    [mailComposer setSubject:@"Spotter"];
    [mailComposer setMessageBody:@"Cool app to spot." isHTML:NO];
    [self presentViewController:mailComposer animated:YES completion:nil];
}


- (void)showMessageVC
{
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


#pragma mark - Message Composer Delegate

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


#pragma mark - Mail Composer Delegate

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Handler Actions

- (IBAction)logoutBtnPressed:(id)sender {
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:YES];
    if (editing == YES) {
        
    } else {
        
    }
}


@end
