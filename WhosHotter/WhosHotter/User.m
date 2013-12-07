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
#import "NotificationNames.h"
#import "TimeManager.h"

#import <Parse/Parse.h>

static User *user = nil;
static int counter = 1;

#define kProfileImageFilename @"user_profile.png"

@interface User ()

@property (nonatomic, readwrite, strong) PFUser *model;
@property (nonatomic, readwrite, strong) PFFile *profileImageFile;

@property (nonatomic, readwrite, strong) Competition *currentCompetition;
@property (nonatomic, readwrite, strong) NSMutableArray *privatePastCompetitions;

@end

@implementation User

+ (User *)sharedUser {
    if (!user) {
        user = [[User alloc] init];
    }
    return user;
}

+ (NSString *)identifier {
    return [[[User sharedUser] model] objectId];
}

+ (NSString *)username {
    return [[[User sharedUser] model] username];
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

+ (void)createFakeUser {
    User *newUser = [[User alloc] init];
    user = newUser;
    NSString *imageName = [NSString stringWithFormat:@"rs_female_0000%02d.jpg",counter];
    [newUser createLogin:[NSString stringWithFormat:@"user_%d",counter]
                password:@"noMatter"
                  gender:FEMALE
                   image:[UIImage imageNamed:imageName]
              completion:nil];
    counter++;
}

- (id)init {
    if (self = [super init]) {
        _model = [PFUser currentUser];
        if (!_model) {
            [self createAnonymousUser];
        } else {
            [_model refreshInBackgroundWithBlock:nil];
        }
    }
    return self;
}

- (NSArray *)pastCompetitions {
    return _privatePastCompetitions;
}

- (NSMutableArray *)privatePastCompetitions {
    if (!_privatePastCompetitions) {
        _privatePastCompetitions = [NSMutableArray array];
    }
    return _privatePastCompetitions;
}

- (void)populate {
    if (self.model) {
        [self getCompetitions:nil];
        [self updateCompetition];
        [self checkStamina];
    }
}

- (void)createAnonymousUser {
    [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (error) {
            NSLog(@"Anonymous login failed.");
        } else {
            _model = user;
            [self addDefaultStatsToUser:_model];
            [_model saveInBackground];
        }
    }];
}

- (void)createLogin:(NSString *)username
           password:(NSString *)password
             gender:(Gender)gender
              image:(UIImage *)profileImage
         completion:(CompletionHandler)handler {
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    [user setObject:@(gender) forKey:@"gender"];
    [user setObject:@(NO) forKey:@"isPaired"];
    [self addDefaultStatsToUser:user];
    
    __weak User *weakSelf = self;
    
    [self setProfileImage:profileImage
     completionHandler:^(BOOL success, NSError *error) {
         if (success) {
             [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 if (succeeded) {
                     weakSelf.model = user;
                     [weakSelf setValue:weakSelf.profileImageFile forKey:@"profileImage"];
                     [weakSelf saveInBackgroundWithCompletionHandler:^(BOOL success, NSError *error) {
                         if (success) {
                             [weakSelf notifyOfUserCreated];
                             [weakSelf submitForCompetition:nil];
                         }
                     }];
                 }
                 
                 if (handler) {
                     handler(succeeded,error);
                 }
             }];
         }
     }];

}

#pragma mark -- model getters
- (NSString *)competitionIdentifier {
    return self.model[@"activeCompetitionIdentifier"];
}

- (NSArray *)pastCompetitionIdentifiers {
    return self.model[@"competitionIdentifiers"];
}

- (void)updateCompetition {
    if ([self isLoggedIn]) {
        if ([self competitionIdentifier]) {
            self.currentCompetition = [Competition objectWithIdentifier:[self competitionIdentifier]
                                                      completionHandler:^(id object, NSError *error) {
                                                          [self checkCompetitionExpiration];
                                                      }];
        } else {
            [self submitForCompetition:nil];
        }
        [self fetchPastCompetitions];
    }
}

- (void)fetchPastCompetitions {
    for (NSString *competitionIdentifier in self.pastCompetitionIdentifiers) {
        [self fetchCompetitionWithIdentifier:competitionIdentifier];
    }
}

- (void)fetchCompetitionWithIdentifier:(NSString *)identifier {
    [Competition cachedObjectWithIdentifier:identifier
                          completionHandler:^(id object, NSError *error) {
                              Competition *competition = (Competition *)object;
                              [self.privatePastCompetitions addObject:competition];
                              if (self.privatePastCompetitions.count == self.pastCompetitionIdentifiers.count) {
                                  [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_COMPETITIONS_UPDATED
                                                                                      object:nil];
                              }
                          }];
}

- (void)checkCompetitionExpiration {
    if ([self.currentCompetition timeUntilExpiration] < 0) {
        [self.currentCompetition setValue:@(YES) forKey:@"final"];
        [self rewardFlamePoints:round(100.0*self.currentCompetition.myRatio)];
        self.currentCompetition = nil;
        [self submitForCompetition:nil];
    }
}

- (void)rewardFlamePoints:(NSInteger)points {
    NSInteger existingPoints = [[self valueForKey:@"points"] intValue];
    [self setValue:@(existingPoints + points) forKey:@"points"];
    [self saveInBackgroundWithCompletionHandler:nil];
}

- (NSInteger)flamePoints {
    return [[self valueForKey:@"points"] intValue];
}

- (BOOL)isLoggedIn {
    return ![PFAnonymousUtils isLinkedWithUser:[PFUser currentUser]] &&
    [PFUser currentUser] != nil &&
    self.model != nil;
}

- (NSString *)userName {
    return self.model.username;
}

- (void)checkStamina {
    if (!self.model) {
        return;
    }
    
    if ([self timeUntilStaminaRefill] <= 0) {
        self.model[@"energy"] = @([Config maxEnergy]);
        self.model[@"timeToRefill"] = @([TimeManager time] + [Config secondsToRecoverStamina]);
        [self.model saveInBackground];
        [self performSelector:@selector(checkStamina) withObject:nil afterDelay:[Config secondsToRecoverStamina]];
    } else {
        [self performSelector:@selector(checkStamina) withObject:nil afterDelay:[self timeUntilStaminaRefill]];
    }
}

- (CGFloat)timeUntilStaminaRefill {
    return [self.model[@"timeToRefill"] floatValue] - [TimeManager time];
}

- (void)notifyOfUserCreated {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_CREATED
                                                        object:nil];
}

- (void)addDefaultStatsToUser:(PFUser *)pfUser {
    pfUser[@"energy"] = @([Config maxEnergy]);
    pfUser[@"timeToRefill"] = @([TimeManager time] + [Config secondsToRecoverStamina]);
}

- (void)setProfileImage:(UIImage *)image
      completionHandler:(CompletionHandler)completionHandler {
    if (image) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
        PFFile *imageFile = [PFFile fileWithData:imageData];
        [FileManager saveData:imageData fileName:kProfileImageFilename];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                self.profileImageFile = imageFile;
            }
            
            if (completionHandler) {
                completionHandler(succeeded,error);
            }
        }];
    }
}

- (void)getCompetitions:(ObjectsCompletionHandler)completionHandler {
    [Competition myRecentCompetitions:9
                    completionHandler:completionHandler];
}

- (void)submitForCompetition:(SingleObjectCompletionHandler)completionHandler {
    [Competition createCompetition:^(id object, NSError *error) {
        if (!error) {
            NSString *competitionIdentifier = (NSString *)object;
            [self fetchCompetitionWithIdentifier:competitionIdentifier];
        }
        
        if (completionHandler) {
            completionHandler(object,error);
        }
    }];
}

- (void)spendEnergy:(NSInteger)energy {
    if (energy > 0 && self.energy >= energy) {
        self.model[@"energy"] = @(self.energy - energy);
        [self.model saveInBackground];
        [self notifyEnergyUpdated];
    }
}

- (NSInteger)energy {
    return [self.model[@"energy"] intValue];
}

- (UIImage *)profileImage {
    return [UIImage imageWithData:[FileManager dataFromFileName:kProfileImageFilename]];
}

- (void)refillEnergy {
    self.model[@"energy"] = @([Config maxEnergy]);
    [self.model saveInBackground];
    [self notifyEnergyUpdated];
}

- (void)notifyEnergyUpdated {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USED_STAMINA
                                                        object:nil
                                                      userInfo:@{@"percent" : @((CGFloat)self.energy / [Config maxEnergy])}];
}

- (void)showError:(NSError *)error {
    
}

@end
