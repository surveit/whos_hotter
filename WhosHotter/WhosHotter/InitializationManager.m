//
//  InitializationManager.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "InitializationManager.h"

#import "User.h"

#import <Parse/Parse.h>

@interface InitializationManager ()


@end

@implementation InitializationManager

- (void)start {
    [Parse setApplicationId:@"ZSuSP6FYo8JfpSgPHrdETAPz8DCCjuGVNXGRXfS3"
                  clientKey:@"xztuf8Gy8RNdecL9l2uKDDlvjz3iLFujk2mLmNez"];
    [PFAnalytics trackAppOpenedWithLaunchOptions:nil];
}

- (void)receivedConfigs {
    
}

@end
