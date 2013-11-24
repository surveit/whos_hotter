//
//  TappableImageView.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/18/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utility.h"

@interface TappableImageView : UIImageView

@property (nonatomic, readwrite, copy) BasicHandler tapHandler;

@end
