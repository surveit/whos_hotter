//
//  Report.m
//  WhosHotter
//
//  Created by Shuhan Bao on 12/9/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "Report.h"

#import "Competition.h"
#import "User.h"

@implementation Report

+ (void)reportWithCompetition:(Competition *)competition {
    Report *newReport = [Report newObject];
    [newReport setValue:[competition valueForKey:@"image0"] forKey:@"image0"];
    [newReport setValue:[competition valueForKey:@"image1"] forKey:@"image1"];
    [newReport setValue:[User identifier] forKey:@"userId"];
    [newReport saveInBackgroundWithCompletionHandler:nil];
}

@end
