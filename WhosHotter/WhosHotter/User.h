//
//  User.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

+ (User *)sharedUser;
+ (NSString *)identifier;

- (void)createLogin:(NSString *)username
           password:(NSString *)password;
- (void)setProfileImage:(UIImage *)image;


@end
