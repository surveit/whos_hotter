//
//  Config.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "Config.h"

@implementation Config

+ (NSInteger)competitionsToCache {
    return 20;
}

+ (NSInteger)maxCommentLength {
    return 140;
}

+ (NSInteger)maxEnergy {
    return 100;
}

+ (double)secondsToRecoverStamina {
    return 1200.0;
}

+ (NSInteger)energyCostPerVote {
    return 5;
}

+ (NSInteger)timePerCompetition {
    return 86400;
}

@end
