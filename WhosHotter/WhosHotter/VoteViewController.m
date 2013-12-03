//
//  VoteViewController.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/18/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "VoteViewController.h"

#import "CommentViewController.h"
#import "Competition.h"
#import "CompetitionCache.h"
#import "Config.h"
#import "TappableImageView.h"
#import "User.h"

@interface VoteViewController ()

@property (weak, nonatomic) IBOutlet UILabel *energyLabel;
@property (weak, nonatomic) IBOutlet UILabel *topPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomPercentageLabel;
@property (nonatomic, readwrite, strong) Competition *currentCompetition;
@property (weak, nonatomic) IBOutlet TappableImageView *topImage;
@property (weak, nonatomic) IBOutlet TappableImageView *bottomImage;
@end

@implementation VoteViewController

- (void)updateView {
    [self.topImage setImage:self.currentCompetition.topImage];
    [self.bottomImage setImage:self.currentCompetition.bottomImage];
    self.topPercentageLabel.text = [NSString stringWithFormat:@"%0.0f%%",[self topPercentage]];
    self.bottomPercentageLabel.text = [NSString stringWithFormat:@"%0.0f%%",[self bottomPercentage]];
}

- (void)tickUpdate {
    if (!self.currentCompetition) {
        self.currentCompetition = [CompetitionCache next];
        if (self.currentCompetition) {
            [self updateView];
        }
    }
    
    [self performSelector:@selector(tickUpdate)
               withObject:nil
               afterDelay:1.0];
}

- (CGFloat)topPercentage {
    if (self.currentCompetition.totalVotes == 0) {
        return 50.0;
    }
    return (CGFloat)self.currentCompetition.votes0/self.currentCompetition.totalVotes*100.0f;
}

- (CGFloat)bottomPercentage {
    if (self.currentCompetition.totalVotes == 0) {
        return 50.0f;
    }
    
    return (CGFloat)self.currentCompetition.votes1/self.currentCompetition.totalVotes*100.0f;
}

- (void)showOutOfEnergyPopup {
    [[[UIAlertView alloc] initWithTitle:@"HI" message:@"OUT OF ENERGY" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil] show];
}

#pragma mark - tap handling
- (void)didTapTop {
    if ([self.currentCompetition canAffrdEnergy]) {
        [self.currentCompetition voteFor0];
        [self didVote];
    } else {
        [self showOutOfEnergyPopup];
    }
}

- (void)didTapBottom {
    if ([self.currentCompetition canAffrdEnergy]) {
        [self.currentCompetition voteFor1];
        [self didVote];
    } else {
        [self showOutOfEnergyPopup];
    }
}

- (void)didVote {
    [self goToNextCompetition];
    [self updateEnergy];
}

- (void)goToNextCompetition {
    [self.topImage setImage:nil];
    [self.bottomImage setImage:nil];
    self.currentCompetition = [CompetitionCache next];
    NSLog(@"current competition %@ %@",self.currentCompetition,self.currentCompetition.identifier);
    [self updateView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"voteToComments"]) {
        CommentViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.competition = self.currentCompetition;
    }
}

- (void)updateEnergy {
    self.energyLabel.text = [NSString stringWithFormat:@"%ld",[[User sharedUser] energy]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self tickUpdate];
    [self updateEnergy];
    
    __weak VoteViewController *weakSelf = self;
    [self.topImage setTapHandler:^(){
        [weakSelf didTapTop];
    }];
    [self.bottomImage setTapHandler:^(){
        [weakSelf didTapBottom];
    }];
    
    self.topImage.userInteractionEnabled = YES;
    self.bottomImage.userInteractionEnabled = YES;
}

@end
