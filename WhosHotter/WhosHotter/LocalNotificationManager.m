//
//  LocalNotificationManager.m
//  WhosHotter
//
//  Created by Shuhan Bao on 12/16/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "LocalNotificationManager.h"

@implementation LocalNotificationManager

+ (void)createLocalNotificationWithText:(NSString *)text time:(NSDate *)time {
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = time;
    notification.alertBody = text;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
