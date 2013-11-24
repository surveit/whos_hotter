//
//  User.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "Utility.h"

typedef enum {
    MALE = 0,
    FEMALE = 1,
} Gender;

@interface User : NSObject

+ (User *)sharedUser;
+ (NSString *)identifier;
+ (NSString *)username;

- (void)createLogin:(NSString *)username
           password:(NSString *)password
             gender:(Gender)gender
         completion:(CompletionHandler)handler;

- (void)setProfileImage:(UIImage *)image;
- (void)getCompetitions:(ObjectsCompletionHandler)completionHandler;
- (void)submitForCompetition:(ObjectsCompletionHandler)completionHandler;
- (UIImage *)profileImage;

@end
