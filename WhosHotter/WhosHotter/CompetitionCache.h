//
//  CompetitionCache.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Competition.h"

@interface CompetitionCache : NSObject

+ (void)initialize;
+ (Competition *)next;

@end
