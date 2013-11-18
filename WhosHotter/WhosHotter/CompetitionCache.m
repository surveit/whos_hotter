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

@interface CompetitionCache ()

@property (nonatomic, readwrite, strong) NSMutableArray *cachedCompetitions;

@end

@implementation CompetitionCache

- (void)populate {
    PFQuery *query = [PFQuery queryWithClassName:NSStringFromClass(Competition.class)];
    query.limit = [Config competitionsToCache];
    CGFloat rand = arc4random_uniform(1000000)/1000000.0f;
    [query whereKey:NSStringFromSelector(@selector(rand)) greaterThan:@(rand)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            for (id object in objects) {
                [self.cachedCompetitions addObject:object];
            }
            
            if (self.cachedCompetitions.count < [Config competitionsToCache]) {
                [self populate];
            }
        }
    }];
}

- (Competition *)next {
    if (self.cachedCompetitions.count > 0) {
        return self.cachedCompetitions.lastObject;
    }
    return nil;
}

@end
