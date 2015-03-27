//
//  RCSupport.m
//  RaceControl
//
//  Created by Jack on 4/8/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import "RCSupport.h"


@implementation RCSupport

+(void)initializeRegistration
{
    
    // check for internet connection
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [Reachability reachabilityForInternetConnection];
    [internetReachable startNotifier];
    
    // NSLog(@"Under init registration function");
    
    
}

//==============================================================================================

+(BOOL)isNetworkAvaialble
{
    Reachability   *internetReachable = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    if (internetStatus == NotReachable)
    {
        
        [RCSupport showAlert:NSLocalizedString(@"NO_NETWORK", nil)];
        return NO;
    }
    return YES;
}
//==============================================================================================

+(void)checkNetworkStatus:(NSNotification *)notice
{
    
    // called after network status changes
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable:
        {
            //NSLog(@"The internet is down.");
            internetActive = NO;
            break;
        }
        case ReachableViaWiFi:
        {
            //NSLog(@"The internet is working via WIFI.");
            internetActive = YES;
            break;
        }
        case ReachableViaWWAN:
        {
            //NSLog(@"The internet is working via WWAN.");
            internetActive = YES;
            break;
        }
    }
    
    // NSLog(@"Under CheckNetworkStatus Function");
    
}

//==============================================================================================

+(BOOL)getNetworkStatus
{
    // NSLog(@"Under get NetworkStatus function");
    return internetActive;
    
}

//==============================================================================================

+(void)unRegistration
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//==============================================================================================

+(void)showAlert:(NSString *)message
{
    
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Warning"
                              message:message delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles: nil];
    [alertView show];
    
}

//================================================================================================

+ (NSString*)getUUID
{
	CFUUIDRef theUUID = CFUUIDCreate(kCFAllocatorDefault);
	NSString *uuid = nil;
	if (theUUID)
    {
		uuid = NSMakeCollectable(CFUUIDCreateString(kCFAllocatorDefault, theUUID));
		CFRelease(theUUID);
	}
    return uuid;
}

//================================================================================================
/*** To return height of text acoording to width and font passed ***/
+ (float)returnHeightOfText:(NSString *)text width:(float)frameWidth font:(UIFont *)font{
	if (text == nil) {
		text = @"NA";
	}
	
	/*CGSize messageSize=[((NSString *)text) sizeWithFont:font
     constrainedToSize:CGSizeMake(frameWidth, 10000.0f)
     lineBreakMode:NSLineBreakByWordWrapping];
     */
    // Calculating rect area for the text display
    CGRect textRect = [text boundingRectWithSize:CGSizeMake(frameWidth, 10000.0f)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];
	float height = textRect.size.height + 16.0f;
    
	return height;
}

// calculating time interval
+ (NSString *) checkTimeIntervalWithStartDate:(NSTimeInterval)interval
{
	NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:interval/1000];
	NSDate *endDate = [NSDate date];
    
	//calculate time diffrence using calender
	NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
	NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit
											   fromDate:startDate
												 toDate:endDate
												options:0];
	//NSLog(@"Difference in date components: %i/%i/%i/%i/%i", components.year, components.month, components.day, components.hour, components.minute);
	NSString *timeForm;
	if (components.year > 0) {
		timeForm = [NSString stringWithFormat:@"%i y", components.year];
	}
	else if (components.month > 0) {
		timeForm = [NSString stringWithFormat:@"%i M", components.month];
	}
	else if (components.day > 0) {
		timeForm = [NSString stringWithFormat:@"%i d", components.day];
	}
	else if (components.hour > 0) {
		timeForm = [NSString stringWithFormat:@"%i h", components.hour];
	}
	else if (components.minute > 0) {
		timeForm = [NSString stringWithFormat:@"%i m", components.minute];
	}
	else {
		timeForm = [NSString stringWithFormat:@"just now"];
	}

	return timeForm;
}

@end
