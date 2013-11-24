//
//  TappableImageView.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/18/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "TappableImageView.h"

@interface TappableImageView ()

@property (nonatomic, readwrite, strong) UITapGestureRecognizer *gestureRecognizer;

@end

@implementation TappableImageView

- (void)setTapHandler:(BasicHandler)tapHandler {
    _tapHandler = [tapHandler copy];
    if (_tapHandler != nil) {
        [self setupTapRecognition];
    } else {
        [self removeTapRecognition];
    }
}

- (void)removeTapRecognition {
    if (self.gestureRecognizer) {
        [self removeGestureRecognizer:self.gestureRecognizer];
        self.gestureRecognizer = nil;
    }
}

- (void)setupTapRecognition {
    if (!self.gestureRecognizer) {
        self.gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:self.gestureRecognizer];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.tapHandler) {
        self.tapHandler();
    }
}

@end
