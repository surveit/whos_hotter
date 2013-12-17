//
//  User.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "User.h"

#import "CommentViewController.h"
#import "Competition.h"
#import "Config.h"
#import "FileManager.h"
#import "LocalNotificationManager.h"
#import "HotterFacebookManager.h"
#import "NotificationNames.h"
#import "TimeManager.h"

#import <Surveit/Surveit.h>
#import <Parse/Parse.h>

static User *user = nil;
static int counter = 1;

#define kProfileImageFilename @"user_profile.png"

@interface User () <UIAlertViewDelegate, SurveitDelegate>

@property (nonatomic, readwrite, strong) PFUser *model;
@property (nonatomic, readwrite, strong) PFFile *profileImageFile;

@property (nonatomic, readwrite, strong) Competition *currentCompetition;
@property (nonatomic, readwrite, strong) NSMutableArray *privatePastCompetitions;

@property (nonatomic, readwrite, strong) UIViewController *energyOfferingViewController;

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
    [newUser createLogin:@"none"
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
            [_model refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [self updateCompetition];
            }];
        }
    }
    return self;
}

- (id)userModel {
    return self.model;
}

- (NSArray *)pastCompetitions {
    return [_privatePastCompetitions sortedArrayUsingComparator:^NSComparisonResult(Competition *obj1, Competition *obj2) {
         return [[obj2 valueForKey:@"startTime"] compare:[obj1 valueForKey:@"startTime"]];
    }];
}

- (NSMutableArray *)privatePastCompetitions {
    if (!_privatePastCompetitions) {
        _privatePastCompetitions = [NSMutableArray array];
    }
    return _privatePastCompetitions;
}

- (void)setProfileImageFile:(PFFile *)profileImageFile {
    _profileImageFile = profileImageFile;
    [self setValue:profileImageFile forKey:@"profileImage"];
}

- (void)populate {
    if (self.model) {
        if ([self isLoggedIn]) {
            [self getCompetitions:nil];
        }
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
    
    self.model = user;
    
    [self setProfileImage:profileImage
     completionHandler:^(BOOL success, NSError *error) {
         if (success) {
             [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 if (succeeded) {
                     weakSelf.model = user;
                     [weakSelf saveInBackgroundWithCompletionHandler:^(BOOL success, NSError *error) {
                         if (success) {
                             [weakSelf notifyOfUserCreated];
                             [weakSelf submitForCompetition:nil];
                             [weakSelf notifyEnergyUpdated];
                         }
                     }];
                 }
                 
                 [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
                 
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
                                                          self.currentCompetition = object;
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
    [Competition objectWithIdentifier:identifier
                    completionHandler:^(id object, NSError *error) {
                        Competition *competition = (Competition *)object;
                        [self.privatePastCompetitions addObject:competition];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_COMPETITIONS_UPDATED
                                                                            object:nil];
                    }];
}

- (void)checkCompetitionExpiration {
    if ([self.currentCompetition timeUntilExpiration] < 0) {
        [self.currentCompetition setValue:@(YES) forKey:@"final"];
        self.currentCompetition = nil;
        [self submitForCompetition:nil];
    }
}

- (NSInteger)flamePoints {
    NSNumber *points = [self valueForKey:@"points"];
    if ([points isKindOfClass:NSNumber.class]) {
        return [[self valueForKey:@"points"] intValue];
    }
    return 0;
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
    
    if ([self energy] > 0) {
        return;
    }
    
    if ([self timeUntilStaminaRefill] <= 0) {
        self.model[@"energy"] = @([Config maxEnergy]);
        [self notifyEnergyUpdated];
        [self.model saveInBackground];
        [self resetTimeToRefill];
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkStamina) object:nil];
        [self performSelector:@selector(checkStamina) withObject:nil afterDelay:[self timeUntilStaminaRefill]];
    }
}

- (void)startRefillTimer {
    [LocalNotificationManager createLocalNotificationWithText:@"You've got more votes! Come check out the new matchups!"
                                                         time:[[NSDate date] dateByAddingTimeInterval:[Config secondsToRecoverStamina]]];
    
    [[NSUserDefaults standardUserDefaults] setObject:@([TimeManager time] + [Config secondsToRecoverStamina]) forKey:@"timeToRefill"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkStamina) object:nil];
    [self performSelector:@selector(checkStamina) withObject:nil afterDelay:(double)[Config secondsToRecoverStamina]];
}

- (void)resetTimeToRefill {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"timeToRefill"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (double)timeUntilStaminaRefill {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:@"timeToRefill"] - [TimeManager time];
}

- (void)notifyOfUserCreated {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_CREATED
                                                        object:nil];
}

- (void)addDefaultStatsToUser:(PFUser *)pfUser {
    pfUser[@"energy"] = @([Config maxEnergy]);
    [self notifyEnergyUpdated];
}

- (void)setProfileImage:(UIImage *)image
      completionHandler:(CompletionHandler)completionHandler {
    if (image) {
        NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
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
            if (competitionIdentifier.length > 0) {
                [self fetchCompetitionWithIdentifier:competitionIdentifier];
            }
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
    
    if (self.energy == 0 && [self timeUntilStaminaRefill] < 0) {
        [self startRefillTimer];
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

- (void)offerEnergyFromViewController:(UIViewController *)controller {
    self.energyOfferingViewController = controller;
    if (![self isLoggedIn]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Out Of Votes!"
                                                            message:@"Upload a photo to refill now?"
                                                           delegate:self
                                                  cancelButtonTitle:@"I'll Wait"
                                                  otherButtonTitles:@"OK",nil];
        [alertView show];
    } else if ([Surveit hasPaidSurvey]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Out Of Votes!"
                                                            message:@"Take a brief survey to refill now?"
                                                           delegate:self
                                                  cancelButtonTitle:@"I'll Wait"
                                                  otherButtonTitles:@"OK",nil];
        [alertView show];
    } else if (![HotterFacebookManager isLoggedInToFacebook]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Out Of Votes!"
                                                            message:@"Sign in with Facebook to refill now?"
                                                           delegate:self
                                                  cancelButtonTitle:@"I'll Wait"
                                                  otherButtonTitles:@"OK",nil];
        [alertView show];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Out Of Votes!"
                                                            message:@"Share something on Facebook to refill now?"
                                                           delegate:self
                                                  cancelButtonTitle:@"I'll Wait"
                                                  otherButtonTitles:@"OK",nil];
        [alertView show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (![self isLoggedIn]) {
            [self.energyOfferingViewController.tabBarController setSelectedIndex:1];
        } else if ([Surveit hasPaidSurvey]) {
            [self performSelector:@selector(showPaidSurvey) withObject:nil afterDelay:0.0];
        } else if (![HotterFacebookManager isLoggedInToFacebook]) {
            [HotterFacebookManager loginWithCompletionHandler:^(BOOL success, NSError *error) {
                [_energyOfferingViewController.tabBarController setSelectedIndex:1];
            }];
        } else if (self.pastCompetitions.count > 0) {
            [self.energyOfferingViewController performSegueWithIdentifier:@"voteToComments" sender:self];
        }
    }
    self.energyOfferingViewController = nil;
}

- (void)showPaidSurvey {
    [Surveit showPaidSurvey];
    [Surveit setSurveitDelegate:self];
}

- (void)surveyDidCompleteWithRewardAmount:(NSInteger)amount ofCurrency:(NSString *)currency {
    [self refillEnergy];
}

@end
