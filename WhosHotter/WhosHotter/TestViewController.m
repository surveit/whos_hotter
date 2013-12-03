//
//  TestViewController.m
//  WhosHotter
//
//  Created by Shuhan Bao on 12/2/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "TestViewController.h"

#import "User.h"

@interface TestViewController ()

@end

@implementation TestViewController


- (IBAction)didTapEnergy:(id)sender {
    [[User sharedUser] refillEnergy];
}

- (IBAction)didTapClose:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

@end
