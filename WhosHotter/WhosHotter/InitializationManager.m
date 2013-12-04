//
//  InitializationManager.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "InitializationManager.h"

#import "User.h"
#import "CompetitionCache.h"
#import "Config.h"
#import "FileCache.h"

#import <Parse/Parse.h>

@interface InitializationManager ()


@end

@implementation InitializationManager

- (void)start {
    [self initializeParse];
    [self initializeCaches];
    [self setupConfig];
#ifdef CREATING_USER_FLOW
    [self performSelector:@selector(createFakeUser) withObject:nil afterDelay:5];
#else
    [self setupUser];
#endif
}

- (void)initializeParse {
    [Parse setApplicationId:@"ZSuSP6FYo8JfpSgPHrdETAPz8DCCjuGVNXGRXfS3"
                  clientKey:@"xztuf8Gy8RNdecL9l2uKDDlvjz3iLFujk2mLmNez"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:nil];
}

- (void)initializeCaches {
    [FileCache initialize];
#ifndef CREATING_USER_FLOW
    [CompetitionCache initialize];
#endif
}

- (void)setupConfig {
    [[UINavigationBar appearance] setBackIndicatorImage:[Utility imageNamed:@"Back button@2x" scale:2.0]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[Utility imageNamed:@"Back button@2x" scale:2.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor clearColor]}];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -50.f) forBarMetrics:UIBarMetricsDefault];
}

- (void)setupUser {
    [[User sharedUser] populate];
}

- (void)createFakeUser {
    [User createFakeUser];
    [self performSelector:@selector(createFakeUser)
               withObject:nil
               afterDelay:15];
}

@end
