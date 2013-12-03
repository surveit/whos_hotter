//
//  BasicNavigationBarView.m
//  WhosHotter
//
//  Created by Shuhan Bao on 12/2/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "BasicNavigationBarView.h"

@interface BasicNavigationBarView ()

@property (weak, nonatomic) IBOutlet UIProgressView *staminaBar;
@property (weak, nonatomic) IBOutlet UIImageView *flameHeader;


@end

@implementation BasicNavigationBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        UIView* xibView = [[[NSBundle mainBundle] loadNibNamed:@"BasicNavigationBar" owner:self options:nil] objectAtIndex:0];
        [self setFrame:frame];
        [self addSubview:xibView];
    }
    return self;
}

@end
