//
//  Config.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Config : NSObject

+ (NSInteger)competitionsToCache;
+ (NSInteger)maxCommentLength;
+ (NSInteger)maxEnergy;
+ (NSInteger)staminaPerVote;
+ (NSInteger)secondsToRecoverStamina;
+ (NSInteger)energyCostPerVote;

@end
