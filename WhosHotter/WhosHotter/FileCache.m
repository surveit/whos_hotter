//
//  FileCache.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/18/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "FileCache.h"
#import "FileManager.h"

#import <Parse/Parse.h>

static NSMutableDictionary *cache = nil;

@implementation FileCache

+ (void)initialize {
    cache = [[NSMutableDictionary alloc] init];
}

+ (void)dataForPFFile:(PFFile *)file completionHandler:(DataCompletionHandler)completionHandler {
    if (cache[file.name]) {
        if (completionHandler) {
            completionHandler(cache[file.name],nil);
        }
        return;
    }
    
    NSData *localData = [FileManager dataFromFileName:file.name];
    if (localData) {
        cache[file.name] = localData;
        if (completionHandler) {
            completionHandler(localData,nil);
        }
        return;
    }
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        cache[file.name] = data;
        [FileManager saveData:data fileName:file.name];
        if (completionHandler) {
            completionHandler(data,error);
        }
    }];
}

@end
