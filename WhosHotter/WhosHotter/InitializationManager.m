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
#import "FileCache.h"

#import <Parse/Parse.h>

@interface InitializationManager ()


@end

@implementation InitializationManager

- (void)start {
    [self initializeParse];
    [self initializeCaches];
    [self setupConfig];
}

- (void)initializeParse {
    [Parse setApplicationId:@"ZSuSP6FYo8JfpSgPHrdETAPz8DCCjuGVNXGRXfS3"
                  clientKey:@"xztuf8Gy8RNdecL9l2uKDDlvjz3iLFujk2mLmNez"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:nil];
}

- (void)initializeCaches {
    [FileCache initialize];
    [CompetitionCache initialize];
}

- (void)setupConfig {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"Fire layer@2x"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"Back button@2x"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"Back button@2x"]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeTextColor : [UIColor whiteColor]}];
}

@end
