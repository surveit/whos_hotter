//
//  FileManager.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+ (void)saveData:(NSData *)image fileName:(NSString *)fileName;
+ (NSData *)dataFromFileName:(NSString *)fileName;

@end
