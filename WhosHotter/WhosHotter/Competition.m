//
//  Competition.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "Competition.h"

#import "Comment.h"
#import "Config.h"
#import "FileCache.h"
#import "NotificationNames.h"
#import "TimeManager.h"
#import "User.h"

static NSMutableArray *myRecentCompetitions = nil;

@interface Competition ()

@property (nonatomic, readwrite, strong) NSData *topImageData;
@property (nonatomic, readwrite, strong) NSData *bottomImageData;
@property (nonatomic, readwrite, assign) BOOL invalid;
@property (nonatomic, readwrite, strong) NSArray *comments;

@property (nonatomic, readwrite, assign) BOOL votedFor0;
@property (nonatomic, readwrite, assign) BOOL votedFor1;

@end

@implementation Competition

+ (NSArray *)myRecentCompetitions:(NSInteger)count completionHandler:(ObjectsCompletionHandler)completionBlock {
    PFQuery *query = [PFQuery queryWithClassName:NSStringFromClass(Competition.class)];
    [query whereKey:@"users" equalTo:[PFUser currentUser]];
    [query orderByDescending:@"createdAt"];
    [query includeKey:@"users"];
    query.limit = count;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        myRecentCompetitions = objects.mutableCopy;
        if (completionBlock) {
            completionBlock(objects,error);
        }
    }];
    
    if (myRecentCompetitions) {
        return myRecentCompetitions;
    }
    return nil;
}

+ (void)createCompetition:(SingleObjectCompletionHandler)completionHandler {
    [PFCloud callFunctionInBackground:@"pairUser"
                       withParameters:@{}
                                block:^(NSString *result, NSError *error) {
                                    NSLog(@"Cloud code result: %@. Error: %@",result, error);
                                    if (completionHandler) {
                                        completionHandler(result,error);
                                    }
                                }];
}

+ (NSArray *)competitionsFromPersistentCompetitions:(NSArray *)objects {
    NSMutableArray *competitions = [NSMutableArray array];
    for (PFObject *persistentCompetition in objects) {
        Competition *competition = [Competition objectWithModel:persistentCompetition];
        [competitions addObject:competition];
    }
    return competitions;
}

- (BOOL)canAffrdEnergy {
    return [[User sharedUser] energy] >= [Config energyCostPerVote];
}

- (void)objectCreatedFromModel {
    [self getImageFromFile:[self valueForKey:@"image0"] saveSelector:@selector(setTopImageData:)];
    [self getImageFromFile:[self valueForKey:@"image1"] saveSelector:@selector(setBottomImageData:)];
    [self getComments];
}

- (void)getComments {
    PFQuery *query = [PFQuery queryWithClassName:NSStringFromClass(Comment.class)];
    [query whereKey:@"competitionIdentifier" equalTo:self.identifier];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.comments = [Comment objectsWithModels:objects];
        } else {
            [Utility showError:error.description];
        }
    }];
}

- (void)addCommentToCache:(Comment *)comment {
    NSMutableArray *mutableComments = self.comments.mutableCopy;
    [mutableComments addObject:comment];
    self.comments = mutableComments;
}

- (void)getImageFromFile:(PFFile *)file saveSelector:(SEL)saveSelector {
    [FileCache dataForPFFile:file
           completionHandler:^(NSData *data, NSError *error) {
               if (!error) {
                   [self performSelector:saveSelector withObject:data];
                   [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_COMPETITIONS_UPDATED object:nil];
               } else {
                   [self markAsInvalid];
               }
           }];
}

- (void)markAsInvalid {
    self.invalid = YES;
}

- (UIImage *)topImage {
    return [UIImage imageWithData:self.topImageData];
}

- (UIImage *)bottomImage {
    return [UIImage imageWithData:self.bottomImageData];
}

- (BOOL)hasAllAssets {
    return self.topImageData != nil && self.bottomImageData != nil;
}

- (NSInteger)votes0 {
    return [[self valueForKey:@"votes0"] floatValue];
}

- (NSInteger)votes1 {
    return [[self valueForKey:@"votes1"] floatValue];
}

- (NSInteger)totalVotes {
    return [self votes0] + [self votes1];
}

- (void)voteFor0 {
    [self incrementKey:@"votes0"];
    [self saveInBackgroundWithCompletionHandler:nil];
    [[User sharedUser] spendEnergy:[Config energyCostPerVote]];
    self.votedFor0 = YES;
}

- (void)voteFor1 {
    [self incrementKey:@"votes1"];
    [self saveInBackgroundWithCompletionHandler:nil];
    [[User sharedUser] spendEnergy:[Config energyCostPerVote]];
    self.votedFor1 = YES;
}

- (NSString *)chosenUsername {
    if (self.votedFor0) {
        return [self valueForKey:@"username0"];
    }
    if (self.votedFor1) {
        return [self valueForKey:@"username1"];
    }
    return nil;
}

- (UIImage *)chosenImage {
    if (self.votedFor0) {
        return [self topImage];
    }
    if (self.votedFor1) {
        return [self bottomImage];
    }
    return nil;
}

- (BOOL)isMyCompetition {
    return [self myIndex] != NSNotFound;
}

- (CGFloat)myRatio {
    NSUInteger index = [self myIndex];
    if (index != NSNotFound && [self totalVotes] > 0) {
        NSInteger votesForMe = index == 0 ? [self votes0] : [self votes1];
        return (CGFloat)votesForMe * 100.0f / [self totalVotes];
    }
    return 50.0f;
}

- (UIImage *)opponentsImage {
    NSUInteger index = [self myIndex];
    if (index != NSNotFound) {
        return index == 0 ? [self bottomImage] : [self topImage];
    }
    return nil;
}

- (NSString *)opponentsUsername {
    NSUInteger index = [self myIndex];
    if (index != NSNotFound) {
        return index == 0 ? [self valueForKey:@"username1"] : [self valueForKey:@"username0"];
    }
    return nil;
}

- (NSInteger)timeUntilExpiration {
    return [[self valueForKey:@"startTime"] doubleValue] / 1000.0f + (double)[Config timePerCompetition] - [TimeManager time];
}

- (NSUInteger)myIndex {
    NSArray *users = [self valueForKey:@"users"];
    if (users) {
        return [[users valueForKey:@"objectId"] indexOfObject:[User identifier]];
    } else {
        return NSNotFound;
    }
}

- (NSArray *)userIdentifiers {
    return [self valueForKey:@"userIdentifiers"];
}

@end