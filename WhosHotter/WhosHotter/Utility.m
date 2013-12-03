//
//  Utility.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/18/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (void)showError:(NSString *)error {
    [[[UIAlertView alloc] initWithTitle:@"ERROR"
                               message:error delegate:nil
                      cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
}

+ (NSString *)percentageStringFromFloat:(CGFloat)value {
    CGFloat percentage = value * 100;
    if (percentage < 10.0) {
        return [NSString stringWithFormat:@"%01.f%%",value];
    }
    return [NSString stringWithFormat:@"%02.f%%",value];
}

@end
