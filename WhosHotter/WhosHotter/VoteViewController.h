//
//  VoteViewController.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/18/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Competition;

@interface VoteViewController : UIViewController

@property (nonatomic, readonly, strong) Competition *currentCompetition;

@end
