//
//  UserCreationViewController.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/24/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "User.h"

@interface UserCreationViewController : UIViewController

@property (nonatomic, readwrite, strong) UIImage *profileImage;
@property (nonatomic, readwrite, assign) Gender gender;

@end
