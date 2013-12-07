//
//  TimeManager.h
//  WhosHotter
//
//  Created by Shuhan Bao on 12/5/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeManager : NSObject

+ (double)time;
+ (void)addTimeModifier:(double)modifier;

@end
