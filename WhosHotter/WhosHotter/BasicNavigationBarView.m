//
//  BasicNavigationBarView.m
//  WhosHotter
//
//  Created by Shuhan Bao on 12/2/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "BasicNavigationBarView.h"

#import "NotificationNames.h"

@interface BasicNavigationBarView ()

@property (weak, nonatomic) IBOutlet UIProgressView *staminaBar;
@property (weak, nonatomic) IBOutlet UIImageView *flameHeader;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic, readwrite, strong) BasicNavigationBarView *actualView;

@end

@implementation BasicNavigationBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.actualView = [[[NSBundle mainBundle] loadNibNamed:@"BasicNavigationBar" owner:self options:nil] objectAtIndex:0];
        [self setFrame:frame];
        [self addSubview:self.actualView];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateStamina:)
                                                     name:NOTIFICATION_USED_STAMINA
                                                   object:nil];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)updateStamina:(NSNotification *)notification {
    CGFloat percent = [notification.userInfo[@"percent"] floatValue];
    [self.actualView.staminaBar setProgress:percent animated:YES];
}

- (CGSize)staminaBarSize {
    UIImage *base = [UIImage imageNamed:@"Energy bar outline@2x"];
    return base.size;
}

- (void)hideEnergy {
    [self.actualView _hideEnergy];
}

- (void)_hideEnergy {
    self.staminaBar.hidden = YES;
    self.flameHeader.hidden = YES;
    self.backButton.hidden = NO;
}

- (void)showEnergy {
    [self.actualView _showEnergy];
}

- (void)_showEnergy {
    self.staminaBar.hidden = NO;
    self.flameHeader.hidden = NO;
    self.backButton.hidden = YES;
}

@end
