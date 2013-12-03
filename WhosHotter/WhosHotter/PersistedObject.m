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

+ (instancetype)objectWithModel:(PFObject *)model {
    PersistedObject *object = [[self alloc] init];
    object.model = model;
    [object objectCreatedFromModel];
    return object;
}

+ (instancetype)objectWithIdentifier:(NSString *)identifier
                   completionHandler:(SingleObjectCompletionHandler)handler {
    PersistedObject *persistedObject = [[self alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:NSStringFromClass(self)];
    [query getObjectInBackgroundWithId:identifier
                                 block:^(PFObject *object, NSError *error) {
                                     if (object) {
                                         persistedObject.model = object;
                                         [persistedObject objectCreatedFromModel];
                                     }
                                     if (handler) {
                                         handler(persistedObject,error);
                                     }
                                 }];
    return persistedObject;
}

+ (instancetype)cachedObjectWithIdentifier:(NSString *)identifier
                         completionHandler:(SingleObjectCompletionHandler)handler {
    PersistedObject *persistedObject = [[self alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:NSStringFromClass(self)];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    [query getObjectInBackgroundWithId:identifier
                                 block:^(PFObject *object, NSError *error) {
                                     if (object) {
                                         persistedObject.model = object;
                                         [persistedObject objectCreatedFromModel];
                                     }
                                     if (handler) {
                                         handler(persistedObject,error);
                                     }
                                 }];
    return persistedObject;
}

+ (NSArray *)objectsWithModels:(NSArray *)models {
    NSMutableArray *objects = [NSMutableArray array];
    for (PFObject *model in models) {
        PersistedObject *object = [self objectWithModel:model];
        [objects addObject:object];
    }
    return objects;
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

- (void)removeObjectForKey:(NSString *)key {
    [self.model removeObjectForKey:key];
}

- (NSString *)identifier {
    return self.model.objectId;
}

- (void)objectCreatedFromModel {
    //do nothing. override
}

@end
