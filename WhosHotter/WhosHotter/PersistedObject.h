//
//  PersistedObject.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import <Parse/Parse.h>
#import "Utility.h"

@interface PersistedObject : NSObject

+ (instancetype)newObject;
+ (instancetype)objectWithModel:(PFObject *)model;
+ (NSArray *)objectsWithModels:(NSArray *)models;
+ (instancetype)objectWithIdentifier:(NSString *)identifier
                   completionHandler:(SingleObjectCompletionHandler)handler;

+ (instancetype)cachedObjectWithIdentifier:(NSString *)identifier
                         completionHandler:(SingleObjectCompletionHandler)handler;

- (id)valueForKey:(NSString *)key;
- (void)incrementKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (void)saveInBackgroundWithCompletionHandler:(void (^)(BOOL success, NSError *error))completionBlock;
- (NSString *)identifier;

@end
