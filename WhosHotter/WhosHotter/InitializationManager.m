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
#import "FacebookManager.h"
#import "HotterFacebookManager.h"
#import "FileCache.h"
#import "User.h"

#import <Crashlytics/Crashlytics.h>
#import <Parse/Parse.h>
#import <Surveit/Surveit.h>

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
    [Crashlytics startWithAPIKey:@"841ee581cc7e652c6644a04164d5638302a00365"];
    [Surveit startSessionWithAppIdentifier:@"755876163"
                                    secret:@"d989606806f643bda4ede02c4d5b131d"
                                 debugMode:NO];
}

- (void)initializeCaches {
    [FileCache initialize];
#ifndef CREATING_USER_FLOW
    [CompetitionCache initialize];
#endif
    if ([[User sharedUser] isLoggedIn]) {
        [HotterFacebookManager initialize];
    }
}

- (void)setupConfig {
    [[UINavigationBar appearance] setBackIndicatorImage:[Utility imageNamed:@"Back button@2x" scale:2.0]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[Utility imageNamed:@"Back button@2x" scale:2.0]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor clearColor]}];
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
