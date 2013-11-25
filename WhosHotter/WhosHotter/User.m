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

+ (BOOL)isUserNameValid:(NSString *)username {
    if ([username rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].location != NSNotFound) {
        return NO;
    }
    if (username.length <= 3) {
        return NO;
    }
    if (username.length > 20) {
        return NO;
    }
    return YES;
}

- (id)init {
    if (self = [super init]) {
        _pfUser = [PFUser currentUser];
        if (!_pfUser) {
            [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
                if (error) {
                    NSLog(@"Anonymous login failed.");
                } else {
                    _pfUser = user;
                    [self addDefaultStatsToUser:_pfUser];
                    [_pfUser saveInBackground];
                }
            }];
        }
    }
    return self;
}

- (BOOL)isLoggedIn {
    return ![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]];
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
    [self addDefaultStatsToUser:user];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.pfUser = user;
        [self submitForCompetition:nil];
        
        if (handler) {
            handler(succeeded,error);
        }
    }];
}

- (void)addDefaultStatsToUser:(PFUser *)pfUser {
    pfUser[@"energy"] = @([Config maxEnergy]);
    pfUser[@"timeToRefill"] = @([Config maxEnergy] * [Config secondsToRecoverStamina]);
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

- (void)spendEnergy:(NSInteger)energy {
    if (energy > 0 && self.energy >= energy) {
        self.pfUser[@"energy"] = @(self.energy - energy);
        NSLog(@"Energy %@",self.pfUser[@"energy"]);
        [self.pfUser saveInBackground];
    }
}

- (NSInteger)energy {
    return [self.pfUser[@"energy"] intValue];
}

- (UIImage *)profileImage {
    return [UIImage imageWithData:[FileManager dataFromFileName:kProfileImageFilename]];
}

- (void)showError:(NSError *)error {
    
}



@end
