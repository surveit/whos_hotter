//
//  User.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "Utility.h"

#import "PersistedObject.h"

typedef enum {
    UNKNOWN = 0,
    MALE = 1,
    FEMALE = 2,
} Gender;

@interface User : PersistedObject

+ (User *)sharedUser;
+ (NSString *)identifier;
+ (NSString *)username;
+ (BOOL)isUserNameValid:(NSString *)username;
+ (void)createFakeUser;


- (void)createLogin:(NSString *)username
           password:(NSString *)password
             gender:(Gender)gender
              image:(UIImage *)profileImage
         completion:(CompletionHandler)handler;

- (void)checkStamina;
- (id)userModel;
- (NSInteger)flamePoints;
- (BOOL)isLoggedIn;
- (UIImage *)profileImage;
- (NSArray *)pastCompetitions;
- (double)timeUntilStaminaRefill;

- (void)getCompetitions:(ObjectsCompletionHandler)completionHandler;
- (void)submitForCompetition:(SingleObjectCompletionHandler)completionHandler;

- (void)spendEnergy:(NSInteger)energy;
- (NSInteger)energy;
- (void)refillEnergy;
- (void)offerEnergyFromViewController:(UIViewController *)controller;

- (void)populate;
- (void)setProfileImage:(UIImage *)image
      completionHandler:(CompletionHandler)completionHandler;

@end
