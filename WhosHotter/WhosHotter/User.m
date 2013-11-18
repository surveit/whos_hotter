//
//  User.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "User.h"
#import "FileManager.h"
#import <Parse/Parse.h>

static User *user = nil;

#define kProfileImageFilename @"user_profile.png"

@interface User ()

@property (nonatomic, readwrite, strong) PFUser *pfUser;

@end

@implementation User

+ (User *)sharedUser {
    if (!user) {
        user = [[User alloc] init];
    }
    return user;
}

+ (NSString *)identifier {
    return [[[User sharedUser] pfUser] objectId];
}

- (id)init {
    if (self = [super init]) {
        _pfUser = [PFUser currentUser];
    }
    return self;
}

- (void)createLogin:(NSString *)username
           password:(NSString *)password {
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    [user setObject:@(NO) forKey:@"isPaired"];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            [self showError:error];
        }
        self.pfUser = user;
    }];
}

- (void)setProfileImage:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            self.pfUser[@"profileImage"] = imageFile;
            [self.pfUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [FileManager saveData:imageData fileName:kProfileImageFilename];
                }
            }];
        }
    }];
}

- (void)getCompetitions {
}

- (UIImage *)profileImage {
    return [UIImage imageWithData:[FileManager dataFromFileName:kProfileImageFilename]];
}

- (void)showError:(NSError *)error {
    
}

@end
