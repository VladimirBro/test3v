//
//  IAPSupport.m
//  StreetFoodMTL_Customer
//
//  Created by medma on 9/27/12 | 39.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "IAPSupport.h"


@implementation IAPSupport

static IAPSupport * _sharedHelper;

+ (IAPSupport *) sharedHelper {
    
    if (_sharedHelper != nil) {
        return _sharedHelper;
    }
    _sharedHelper = [[IAPSupport alloc] init];
    return _sharedHelper;
    
}

- (id)init {
	
	/* NSSet *productIdentifiers = [NSSet setWithObjects:
	 @"com.fastup.inapprage.fire1",
	 @"com.fastup.inapprage.water",
	 @"com.fastup.inapprage.land",
	 @"com.fastup.inapprage.lifetimesubcription",
	 nil];*/
    
    if ((self = [super initWithProductIdentifiers:nil])) {                
        
    }
    return self;
    
}

@end
