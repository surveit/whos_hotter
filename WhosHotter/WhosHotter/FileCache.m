//
//  FileCache.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/18/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "FileCache.h"

#import <Parse/Parse.h>

static NSMutableDictionary *cache = nil;

@implementation FileCache

+ (void)initialize {
    cache = [[NSMutableDictionary alloc] init];
}

+ (void)dataForPFFile:(PFFile *)file completionHandler:(DataCompletionHandler)completionHandler {
    if (cache[file.url]) {
        if (completionHandler) {
            completionHandler(cache[file.url],nil);
        }
        return;
    }
    
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        cache[file.url] = data;
        if (completionHandler) {
            completionHandler(data,error);
        }
    }];
}

@end
