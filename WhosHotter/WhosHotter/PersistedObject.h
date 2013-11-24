//
//  PersistedObject.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import <Parse/Parse.h>



@interface PersistedObject : NSObject

+ (instancetype)newObject;
+ (instancetype)objectWithModel:(PFObject *)model;
+ (NSArray *)objectsWithModels:(NSArray *)models;

- (id)valueForKey:(NSString *)key;
- (void)incrementKey:(NSString *)key;
- (void)setValue:(id)value forKey:(NSString *)key;
- (void)saveInBackgroundWithCompletionHandler:(void (^)(BOOL success, NSError *error))completionBlock;
- (NSString *)identifier;

@end
