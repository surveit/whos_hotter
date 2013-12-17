//
//  LocalNotificationManager.h
//  WhosHotter
//
//  Created by Shuhan Bao on 12/16/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalNotificationManager : NSObject

+ (void)createLocalNotificationWithText:(NSString *)text time:(NSDate *)time;

@end
