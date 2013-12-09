//
//  BlurView.m
//  WhosHotter
//
//  Created by Shuhan Bao on 12/8/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "BlurView.h"

@implementation BlurView

- (id) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self setup];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)coder
{
    if ((self = [super initWithCoder:coder]))
    {
        [self setup];
    }
    return self;
}

- (void) setup
{
    if (YES)
    {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        toolbar.barTintColor = nil;
        toolbar.translucent = YES;
        [self insertSubview:toolbar atIndex:0];
    }
}

@end
