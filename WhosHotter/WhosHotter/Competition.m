//
//  Competition.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "Competition.h"
#import "User.h"

static NSMutableArray *myRecentCompetitions = nil;

@implementation Competition

+ (NSArray *)myRecentCompetitions:(NSInteger)count completionHandler:(void (^)(BOOL success, NSError *error))completionBlock {
    PFQuery *query = [PFQuery queryWithClassName:NSStringFromClass(Competition.class)];
    [query whereKey:@"userIdentifiers" containsString:[User identifier]];
    [query orderByDescending:@"createdAt"];
    query.limit = count;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        myRecentCompetitions = objects.mutableCopy;
        completionBlock(objects != nil,error);
    }];
    
    if (myRecentCompetitions) {
        return myRecentCompetitions;
    }
    return nil;
}

- (NSInteger)votes0 {
    return [[self valueForKey:@"votes0"] floatValue];
}

- (NSInteger)votes1 {
    return [[self valueForKey:@"votes1"] floatValue];
}

- (void)voteFor0 {
    [self incrementKey:@"votes0"];
    [self saveInBackgroundWithCompletionHandler:nil];
}

- (void)voteFor1 {
    [self incrementKey:@"votes1"];
    [self saveInBackgroundWithCompletionHandler:nil];
}

@end