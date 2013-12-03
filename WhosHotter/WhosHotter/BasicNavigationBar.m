//
//  BasicNavigationBar.m
//  WhosHotter
//
//  Created by Shuhan Bao on 12/2/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "BasicNavigationBar.h"

#import "BasicNavigationBarView.h"

@interface BasicNavigationBar ()

@property (nonatomic, readwrite, strong) BasicNavigationBarView *barView;

@end

@implementation BasicNavigationBar

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview && !_barView) {
        [self addSubview:self.barView];
    }
}

- (void)changedTopViewController {
    if (self.items.count == 1) {
        [self.barView showEnergy];
    } else {
        [self.barView hideEnergy];
    }
}

- (UIView *)barView {
    if (!_barView) {
        _barView = [[BasicNavigationBarView alloc] initWithFrame:[self bounds]];
    }
    return _barView;
}

@end
