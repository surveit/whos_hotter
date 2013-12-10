//
//  Report.h
//  WhosHotter
//
//  Created by Shuhan Bao on 12/9/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "PersistedObject.h"

@class Competition;

@interface Report : PersistedObject

+ (void)reportWithCompetition:(Competition *)competition;

@end
