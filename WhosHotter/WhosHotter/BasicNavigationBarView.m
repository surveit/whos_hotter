//
//  BasicNavigationBarView.m
//  WhosHotter
//
//  Created by Shuhan Bao on 12/2/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "BasicNavigationBarView.h"

#import "Config.h"
#import "NotificationNames.h"
#import "User.h"
#import "Utility.h"

@interface BasicNavigationBarView ()

@property (weak, nonatomic) IBOutlet UIProgressView *staminaBar;
@property (weak, nonatomic) IBOutlet UIImageView *flameHeader;
@property (nonatomic, readwrite, strong) BasicNavigationBarView *actualView;
@property (weak, nonatomic) IBOutlet UILabel *refillCountdown;

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
                                                 selector:@selector(updateStaminaFromNotification:)
                                                     name:NOTIFICATION_USED_STAMINA
                                                   object:nil];
        self.userInteractionEnabled = NO;
        
        UIImage *progressImage = [Utility imageNamed:@"Energy bar filler@2x" scale:2.0];
        [self.actualView.staminaBar setProgressImage:progressImage];
        [self.actualView.staminaBar setTrackImage:[Utility imageNamed:@"Energy bar outline@2x" scale:2.0]];
        self.actualView.staminaBar.frame = CGRectMake(self.actualView.staminaBar.frame.origin.x,
                                                      self.actualView.staminaBar.frame.origin.y,
                                                      progressImage.size.width,
                                                      progressImage.size.height);
        [self updateStamina:[self progress]];
    }
    return self;
}

- (CGFloat)progress {
    return (CGFloat)[[User sharedUser] energy] / [Config maxEnergy];
}

- (void)updateStaminaFromNotification:(NSNotification *)notification {
    CGFloat percent = [notification.userInfo[@"percent"] floatValue];
    [self updateStamina:percent];
}

- (void)updateStamina:(CGFloat)percent {
    if (percent == 0) {
        self.actualView.staminaBar.hidden = YES;
        self.actualView.refillCountdown.hidden = NO;
        [self updateCountdown];
    } else {
        self.actualView.refillCountdown.hidden = YES;
        self.actualView.staminaBar.hidden = NO;
        [self.actualView.staminaBar setProgress:percent animated:YES];
        [self removeCountdown];
    }
}

- (void)updateCountdown {
    self.actualView.refillCountdown.text = [Utility getMMSSFromSeconds:MAX(0,(NSInteger)[[User sharedUser] timeUntilStaminaRefill])];
    [self performSelector:@selector(updateCountdown) withObject:nil afterDelay:1.0];
}

- (void)removeCountdown {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (CGSize)staminaBarSize {
    UIImage *base = [UIImage imageNamed:@"Energy bar outline@2x"];
    return base.size;
}

- (void)hideEnergy {
    [self.actualView _hideEnergy];
}

- (void)_hideEnergy {
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.staminaBar.alpha = 0;
                         self.flameHeader.alpha = 0;
                         self.refillCountdown.alpha = 0;
                     }];
}

- (void)showEnergy {
    [self.actualView _showEnergy];
}

- (void)_showEnergy {
    [UIView animateWithDuration:0.4
                     animations:^{
                         self.staminaBar.alpha = 1;
                         self.flameHeader.alpha = 1;
                         self.refillCountdown.alpha = 1;
                     }];
}

@end
