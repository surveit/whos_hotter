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
    [[[UIAlertView alloc] initWithTitle:@"Error"
                               message:error delegate:nil
                      cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

+ (NSString *)percentageStringFromFloat:(CGFloat)value {
    CGFloat percentage = value * 100;
    if (percentage < 10.0) {
        return [NSString stringWithFormat:@"%.f%%",value];
    }
    return [NSString stringWithFormat:@"%02.f%%",value];
}

+ (CGPoint)addPoint:(CGPoint)p1 to:(CGPoint)p2 {
    return CGPointMake(p1.x + p2.x, p1.y+p2.y);
}

+ (CGPoint)multiplyPoint:(CGPoint)p1 scalar:(CGFloat)s {
    return CGPointMake(p1.x*s, p1.y*s);
}

+ (UIImage *)imageNamed:(NSString *)name scale:(CGFloat)scale {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    UIImage *image = [UIImage imageWithData:data scale:scale];
    return image;
}

+ (NSString *)getHHMMSSFromSeconds:(NSInteger)seconds {
    NSInteger hours = seconds / 3600;
    seconds %= 3600;
    NSInteger minutes = seconds / 60;
    seconds %= 60;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours,(long)minutes,(long)seconds];
}

+ (NSString *)getMMSSFromSeconds:(NSInteger)seconds {
    NSInteger minutes = seconds / 60;
    seconds %= 60;
    return [NSString stringWithFormat:@"%02ld:%02ld",(long)minutes,(long)seconds];
}


@end
