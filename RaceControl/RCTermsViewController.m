//
//  RCTermsViewController.m
//  RaceControl
//
//  Created by Sabir on 5/10/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import "RCTermsViewController.h"

@interface RCTermsViewController ()

@end

@implementation RCTermsViewController

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
    NSURL *url = [NSURL URLWithString:API_TERMS_CONDITION];
    NSURLRequest *urlReqest = [NSURLRequest requestWithURL:url];
    [termsWebView loadRequest:urlReqest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



#pragma mark -
#pragma mark WEB VIEW DELEGATE METHODS
- (void) webViewDidStartLoad:(UIWebView *)webView{
	//NSLog(@"webViewDidStartLoad");
}

- (void) webViewDidFinishLoad:(UIWebView *)webView{
	//NSLog(@"webViewDidFinishLoad");
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
	//NSLog(@"error : %@", error);
}


@end
