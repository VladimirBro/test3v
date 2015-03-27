//
//  CustomNaviPhone.m
//  MDSpyCam
//
//  Created by Medma Infomatix on 15/05/13.
//  Copyright (c) 2013 Medma Infomatix. All rights reserved.
//

#import "CustomNaviPhone.h"

@interface CustomNaviPhone ()

@end

@implementation CustomNaviPhone

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}


@end
