//
//  TimeManager.m
//  WhosHotter
//
//  Created by Shuhan Bao on 12/5/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "TimeManager.h"

static double timeModifier = 0;

@implementation TimeManager

+ (void)addTimeModifier:(double)modifier {
    double newModifier = [self timeModifier] + modifier;
    [[NSUserDefaults standardUserDefaults] setDouble:newModifier forKey:@"timeModifier"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (double)timeModifier {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:@"timeModifier"];
}

+ (double)time {
    return [[NSDate date] timeIntervalSince1970] + timeModifier;
}

@end
