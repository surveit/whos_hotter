//
//  FacebookManager.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/23/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "Utility.h"
#import "User.h"

@interface FacebookManager : NSObject

+ (void)loginWithCompletionHandler:(CompletionHandler)handler;
+ (BOOL)isLoggedInToFacebook;
+ (void)initialize;

+ (UIImage *)profileImage;
+ (Gender)gender;

@end
