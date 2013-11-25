//
//  User.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "Utility.h"

typedef enum {
    UNKNOWN = 0,
    MALE = 1,
    FEMALE = 2,
} Gender;

@interface User : NSObject

+ (User *)sharedUser;
+ (NSString *)identifier;
+ (NSString *)username;
+ (BOOL)isUserNameValid:(NSString *)username;

- (void)createLogin:(NSString *)username
           password:(NSString *)password
             gender:(Gender)gender
         completion:(CompletionHandler)handler;

- (BOOL)isLoggedIn;
- (void)setProfileImage:(UIImage *)image;
- (void)getCompetitions:(ObjectsCompletionHandler)completionHandler;
- (void)submitForCompetition:(ObjectsCompletionHandler)completionHandler;
- (UIImage *)profileImage;

- (void)spendEnergy:(NSInteger)energy;
- (NSInteger)energy;

@end
