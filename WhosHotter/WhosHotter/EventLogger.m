//
//  EventLogger.m
//  WhosHotter
//
//  Created by Shuhan Bao on 12/8/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "EventLogger.h"

#import <Parse/Parse.h>

@implementation EventLogger

+ (void)logEvent:(NSString *)event {
    [PFAnalytics trackEvent:event];
}

@end
