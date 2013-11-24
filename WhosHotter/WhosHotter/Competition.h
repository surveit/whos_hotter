//
//  Competition.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "PersistedObject.h"

#import "Downloadable.h"
#import "Utility.h"

@interface Competition : PersistedObject <Downloadable>

+ (NSArray *)myRecentCompetitions:(NSInteger)count
                completionHandler:(ObjectsCompletionHandler)completionBlock;
+ (void)createCompetition:(CompletionHandler)completionHandler;

+ (NSArray *)competitionsFromPersistentCompetitions:(NSArray *)objects;

@property (nonatomic, readonly, assign) BOOL invalid;

- (NSInteger)votes0;
- (NSInteger)votes1;
- (NSInteger)totalVotes;

- (void)voteFor0;
- (void)voteFor1;

- (UIImage *)topImage;
- (UIImage *)bottomImage;
- (NSArray *)comments;

@end
