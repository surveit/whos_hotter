//
//  PersistedObject.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "PersistedObject.h"

@interface PersistedObject ()

@property (nonatomic, readwrite, strong) PFObject *model;

@end

@implementation PersistedObject

+ (instancetype)newObject {
    PersistedObject *object = [[self alloc] init];
    object.model = [PFObject objectWithClassName:NSStringFromClass(self)];
    return object;
}

- (void)saveInBackgroundWithCompletionHandler:(void (^)(BOOL success, NSError *error))completionBlock {
    [self.model saveInBackgroundWithBlock:completionBlock];
}

- (id)valueForKey:(NSString *)key {
    return [self.model objectForKey:key];
}

- (void)incrementKey:(NSString *)key {
    [self.model incrementKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    [self.model setObject:value forKey:key];
}

@end
