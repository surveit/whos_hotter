//
//  HotterFacebookManager.h
//  WhosHotter
//
//  Created by Shuhan Bao on 12/10/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "FacebookManager.h"

@interface HotterFacebookManager : FacebookManager

+ (void)postPhoto:(UIImage *)image
         username:(NSString *)username;

@end
