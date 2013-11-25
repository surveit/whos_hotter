//
//  FacebookManager.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/23/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "Utility.h"

@interface FacebookManager : NSObject

+ (void)loginWithCompletionHandler:(CompletionHandler)handler;

@end
