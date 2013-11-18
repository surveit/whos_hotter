//
//  Competition.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "PersistedObject.h"

@interface Competition : PersistedObject

+ (NSArray *)myRecentCompetitions:(NSInteger)count
                completionHandler:(void (^)(BOOL success, NSError *error))completionBlock;

- (NSInteger)votes0;
- (NSInteger)votes1;

- (void)voteFor0;
- (void)voteFor1;

@end
