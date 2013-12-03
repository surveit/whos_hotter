//
//  Utility.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/18/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionHandler)(BOOL success, NSError *error);
typedef void (^SingleObjectCompletionHandler)(id object, NSError *error);
typedef void (^ObjectsCompletionHandler)(NSArray *objects, NSError *error);
typedef void (^DataCompletionHandler)(NSData *data, NSError *error);
typedef void (^BasicHandler)();;

@interface Utility : NSObject

+ (void)showError:(NSString *)error;
+ (NSString *)percentageStringFromFloat:(CGFloat)value;

@end
