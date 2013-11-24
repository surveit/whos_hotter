//
//  User.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "User.h"

#import "Competition.h"
#import "Config.h"
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

+ (NSString *)username {
    return [[[User sharedUser] pfUser] username];
}

- (id)init {
    if (self = [super init]) {
        _pfUser = [PFUser currentUser];
    }
    return self;
}

- (NSString *)userName {
    return self.pfUser.username;
}

- (void)createLogin:(NSString *)username
           password:(NSString *)password
             gender:(Gender)gender
         completion:(CompletionHandler)handler {
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    [user setObject:@(gender) forKey:@"gender"];
    [user setObject:@(NO) forKey:@"isPaired"];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.pfUser = user;
        if (handler) {
            handler(succeeded,error);
        }
    }];
}

- (void)setProfileImage:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    PFFile *imageFile = [PFFile fileWithData:imageData];
    [FileManager saveData:imageData fileName:@"profileImage.png"];
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

- (void)getCompetitions:(ObjectsCompletionHandler)completionHandler {
    [Competition myRecentCompetitions:10
                    completionHandler:completionHandler];
}

- (void)submitForCompetition:(ObjectsCompletionHandler)completionHandler {
    [Competition createCompetition:^(BOOL success, NSError *error) {
        if (success) {
            [self getCompetitions:completionHandler];
        }
    }];
}

- (UIImage *)profileImage {
    return [UIImage imageWithData:[FileManager dataFromFileName:kProfileImageFilename]];
}

- (void)userCreated {
    self.pfUser[@"stamina"] = @([Config maxStamina]);
    self.pfUser[@"timeToRefill"] = @([Config maxStamina] * [Config secondsToRecoverStamina]);
    
    [self.pfUser saveEventually];
}

- (void)showError:(NSError *)error {
    
}

@end
