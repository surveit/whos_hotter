//
//  HotterFacebookManager.h
//  WhosHotter
//
//  Created by Shuhan Bao on 12/10/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "FacebookManager.h"

@class Competition;

@interface HotterFacebookManager : FacebookManager

+ (void)shareCompetition:(Competition *)competition;

@end
