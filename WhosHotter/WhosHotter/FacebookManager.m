//
//  FacebookManager.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/23/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "FacebookManager.h"

#import <Parse/Parse.h>

@implementation FacebookManager

+ (void)login {
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils initializeFacebook];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
    }];
}

@end
