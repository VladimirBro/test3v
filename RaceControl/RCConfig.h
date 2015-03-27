//
//  RCConfig.h
//  RaceControl
//
//  Created by Jack on 4/8/14.
//  Copyright (c) 2014 Technologies33. All rights reserved.
//

#import <Foundation/Foundation.h>

// Pubnub Configuration

#define PUBNUB_ORIGIN               @"pubsub.pubnub.com"
#define PUBNUB_PUBLISH_KEY          @"pub-c-58518934-1b00-4736-9b35-c2725e5979ee"
#define PUBNUB_SUBSCRIBE_KEY        @"sub-c-60b7010c-5177-11e3-a6da-02ee2ddab7fe"
#define PUBNUB_SECRET_KEY           @"sec-c-NzlmNWY4M2QtOWU1OS00OTVlLTk1ZjgtNmRjZTViNjM0YWE0"


#define EMAIL_REGEX     @"[A-Z0-9a-z]+[A-Z0-9a-z._]+[A-Z0-9a-z]@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"

#define CAR_NUMBER      @"car_number"
#define DEVICE_TOKEN    @"DeviceToken"
#define ACCESS_TOKEN    @"access_token"
#define CLIENT_SECRET   @"db115f500bfb4039803a1656f5811b5a"
#define CLIENT_ID       @"b4214f8897d64c6cb8b93b647e6eb3d6"
#define CLIENT_PLATFORM @"ios"

#define CHANNEL_MSG_NOTIFICATION                    @"CHANELL_MSG_NOTIFICATION"
#define CHANNEL_SUBSCRIPTION_SUCCESS_NOTIFICATION   @"CHANNEL_SUBSCRIPTION_SUCCESS_NOTIFICATION"
#define CHANNEL_SUBSCRIPTION_FAILED_NOTIFICATION    @"CHANNEL_SUBSCRIPTION_FAILED_NOTIFICATION"

#define PUSH_MESSAGE_NOTIFICATION    @"PUSH_MESSAGE_NOTIFICATION"


//Development Server URLs
//#define API_USER_REGISTER   @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/users"
//#define API_USER_LOGIN      @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/users/auth"
//#define API_USER_LOGOUT     @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/users/auth"
//#define API_GET_TRACK       @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/spotter/nearesttrack"
//#define API_GET_EVENT       @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/spotter/getevents"
//#define API_GET_FEED        @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/feed/getfeed"
//#define API_SAVE_PURCHASE   @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/users/savepurchase"
//#define API_VERIFY_PURCHASE @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/users/pro"
//#define API_ACKNOWLEDGEMENT @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/spotter/ack"
//#define API_TRACK_FEEDS     @"http://mruniverse-ci.elasticbeanstalk.com/trackfeeds"

//Development Server URLs
#define API_USER_REGISTER   @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/users"
#define API_USER_LOGIN      @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/users/auth"
#define API_USER_LOGOUT     @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/users/auth"
#define API_GET_TRACK       @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/spotter/nearesttrack"
#define API_GET_EVENT       @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/spotter/getevents"
#define API_GET_FEED        @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/feed/getfeed"
#define API_SAVE_PURCHASE   @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/users/savepurchase"
#define API_VERIFY_PURCHASE @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/users/pro"
#define API_ACKNOWLEDGEMENT @"http://spotter-ci-qpemczmudb.elasticbeanstalk.com/spotter/ack"
#define API_TRACK_FEEDS     @"http://mruniverse-ci.elasticbeanstalk.com/trackfeeds"

// Production Server URLs
//#define API_USER_REGISTER   @"http://spotterservice-env.elasticbeanstalk.com/users"
//#define API_USER_LOGIN      @"http://spotterservice-env.elasticbeanstalk.com/users/auth"
//#define API_USER_LOGOUT     @"http://spotterservice-env.elasticbeanstalk.com/users/auth"
//#define API_GET_TRACK       @"http://spotterservice-env.elasticbeanstalk.com/spotter/nearesttrack"
//#define API_GET_EVENT       @"http://spotterservice-env.elasticbeanstalk.com/spotter/getevents"
//#define API_GET_FEED        @"http://spotterservice-env.elasticbeanstalk.com/feed/getfeed"
//#define API_SAVE_PURCHASE   @"http://spotterservice-env.elasticbeanstalk.com/users/savepurchase"
//#define API_VERIFY_PURCHASE @"http://spotterservice-env.elasticbeanstalk.com/users/pro"
//#define API_ACKNOWLEDGEMENT @"http://spotterservice-env.elasticbeanstalk.com/spotter/ack"
//#define API_TRACK_FEEDS     @"http://mruniverse-env.elasticbeanstalk.com/trackfeeds"


#define API_TERMS_CONDITION @"http://www.spotter.com.s3-website-us-east-1.amazonaws.com/agreement.html"

#define SEGUE_ID_FLAG_FROM_LOGIN        @"PushFlagFromLogin"
#define SEGUE_ID_FLAG_FROM_REGISTER     @"PushFlagFromRegister"
#define SEGUE_ID_FLAG_FROM_FBSignUp     @"PushFlagFromFBSignUp"
#define SEGUE_ID_SPOTTER_FROM_HOME      @"PushSpotterFromHome"
#define SEGUE_ID_LOGIN_FROM_SPLASH      @"PushLoginFromSplash"
#define SEGUE_ID_REGISTER_FROM_SPLASH   @"PushRegisterFromSplash"
#define SEGUE_ID_REGISTER_FROM_LOGIN    @"PushRegisterFromLogin"
#define SEGUE_ID_FBSignUpFromSplash     @"PushFBSignUpFromSplash"
#define SEGUE_ID_FBSignUpFromLogin      @"PushFBSignUpFromLogin"
#define SEGUE_ID_FlagFromSplash         @"PushFlagFromSplash"
#define SEGUE_ID_SettingsFromHome       @"PushHomeToSettings"
#define SEGUE_ID_CarFromFBSignUp        @"PushCarFromFBSignUp"
#define SEGUE_ID_CarFromSignUp          @"PushCarFromSignUp"
#define SEGUE_ID_CarFromHome            @"PushHomeToSettings" // @"PushCarFromHome"
#define SEGUE_ID_FlagFromCar            @"PushFlagFromCar"
#define SEGUE_ID_CarFromSettings        @"PushCarFromSettings"


#define IOS_VERSION      [[[UIDevice currentDevice] systemVersion] floatValue]

#define EMAIL_TEXT      @"email"
#define PASSWORD_TEXT   @"password"

#define CELL_UPPER_MARGIN       12.0f
#define CELL_LOWER_MARGIN       12.0f
#define CELL_MIN_HEIGHT         54.0f

// InApp Purchase Ids
#define MONTHLY_SPOTTER_ID @"com.spotter.app.monthly"
#define YEARLY_SPOTTER_ID  @"com.spotter.app.yearly"

// SKU Values
#define SKU_MONTHLY @"onemonth"
#define SKU_YEARLY @"oneyear"

// distance radius
#define DISTANCE_RADIUS @"1000" //DISTANCE_RADIUS @"50"

// Color
#define grayColor           [[UIColor lightGrayColor] CGColor]
#define YELLOW_COLOR        [UIColor colorWithRed:237.0/255 green:228.0/255 blue:58.0/255 alpha:1.0]
#define BLACK_COLOR         [UIColor colorWithRed:43.0/255 green:43.0/255 blue:43.0/255 alpha:1.0]
#define FLAG_BLACK_COLOR    [UIColor colorWithRed:53.0/255 green:53.0/255 blue:53.0/255 alpha:1.0]
#define FLAG_BORDER_COLOR   [UIColor colorWithRed:191.0/255 green:191.0/255 blue:191.0/255 alpha:1.0]

typedef enum{
    ASIHttpRequestTagLogin,
    ASIHttpRequestTagFBLogin,
    ASIHttpRequestTagRegistration,
} ASIHttpRequestTag;




