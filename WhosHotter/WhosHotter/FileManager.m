//
//  FileManager.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "FileManager.h"

static NSString *cachedFilePath = nil;

@implementation FileManager

+ (NSString *)cachedFilesPath {
    if (!cachedFilePath) {
        NSString *cachedFilesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        [self createDirectoryAtPath:cachedFilesPath];
        cachedFilePath = cachedFilesPath;
    }
    return cachedFilePath;
}

+ (void)createDirectoryAtPath:(NSString *)path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&(BOOL){NO}]) {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
}

+ (void)saveData:(NSData *)image fileName:(NSString *)fileName {
    NSString *filePath = [[self.class cachedFilesPath] stringByAppendingPathComponent:fileName];
    [image writeToFile:filePath atomically:YES];
}

+ (NSData *)dataFromFileName:(NSString *)fileName {
    NSString *filePath = [[self.class cachedFilesPath] stringByAppendingPathComponent:fileName];
    return [NSData dataWithContentsOfFile:filePath];
}

@end
