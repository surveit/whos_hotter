//
//  FileCache.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/18/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Utility.h"

@class PFFile;

@interface FileCache : NSObject

+ (void)initialize;
+ (void)dataForPFFile:(PFFile *)file completionHandler:(DataCompletionHandler)completionHandler;

@end
