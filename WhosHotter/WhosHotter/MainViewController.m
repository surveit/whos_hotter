//
//  MainViewController.m
//  WhosHotter
//
//  Created by Shuhan Bao on 12/2/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "MainViewController.h"

#import "BasicNavigationBar.h"

@implementation MainViewController

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [(BasicNavigationBar *)self.navigationBar changedTopViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
}

@end