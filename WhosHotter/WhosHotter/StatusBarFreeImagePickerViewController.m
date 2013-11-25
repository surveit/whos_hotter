//
//  StatusBarFreeImagePickerViewController.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/24/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "StatusBarFreeImagePickerViewController.h"

@interface StatusBarFreeImagePickerViewController ()

@end

@implementation StatusBarFreeImagePickerViewController

-(BOOL) prefersStatusBarHidden {
    return YES;
}

-(UIViewController *) childViewControllerForStatusBarHidden {
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)   // iOS7+ only
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

@end
