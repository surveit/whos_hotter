//
//  CompetitionCache.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "CompetitionCache.h"
#import "Config.h"

#import <Parse/Parse.h>

static CompetitionCache *sharedInstance = nil;

@interface CompetitionCache ()

@property (nonatomic, readwrite, strong) Competition *currentCompetition;
@property (nonatomic, readwrite, strong) NSMutableArray *cachedCompetitions;

@end

@implementation CompetitionCache

+ (CompetitionCache *)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[CompetitionCache alloc] init];
    }
    return sharedInstance;
}

+ (void)initialize {
    [[self sharedInstance] populate];
}

+ (Competition *)next {
    return [[self sharedInstance] next];
}

- (void)populate {
    PFQuery *query = [PFQuery queryWithClassName:NSStringFromClass(Competition.class)];
    [query whereKey:@"isFinal" equalTo:@(NO)];
    [query whereKey:@"random" greaterThan:@(arc4random_uniform(9000)/10000.0f)];
    query.limit = [Config competitionsToCache];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (!self.cachedCompetitions) {
                self.cachedCompetitions = [NSMutableArray array];
            }
            
            [self.cachedCompetitions addObjectsFromArray:[Competition competitionsFromPersistentCompetitions:objects]];
            
            if (self.cachedCompetitions.count < [Config competitionsToCache]) {
                [self populate];
            }
        } else {
            NSLog(@"ERROR %@",error);
            [self populate];
        }
    }];
}

- (Competition *)next {
    self.currentCompetition = nil;
    
    for (Competition *competition in self.cachedCompetitions) {
        if ([competition hasAllAssets] && [competition timeUntilExpiration] > 600.0f) {
            self.currentCompetition = competition;
            break;
        }
    }
    
    [self.cachedCompetitions removeObject:self.currentCompetition];
    [self removeInvalidCompetitions];
    
    if (self.cachedCompetitions.count < [Config competitionsToCache]) {
        [self populate];
    }
    
    return self.currentCompetition;
}

- (void)removeInvalidCompetitions {
    NSMutableArray *invalidCompetitions = [NSMutableArray array];
    for (Competition *competition in self.cachedCompetitions) {
        if ([competition invalid]) {
            [invalidCompetitions addObject:competition];
        }
    }
    
    [self.cachedCompetitions removeObjectsInArray:invalidCompetitions];
}

@end
