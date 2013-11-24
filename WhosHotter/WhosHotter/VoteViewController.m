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
#import "TappableImageView.h"

@interface VoteViewController ()

@property (weak, nonatomic) IBOutlet UILabel *topPercentageLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomPercentageLabel;
@property (nonatomic, readwrite, strong) Competition *currentCompetition;
@property (weak, nonatomic) IBOutlet TappableImageView *topImage;
@property (weak, nonatomic) IBOutlet TappableImageView *bottomImage;
@end

@implementation VoteViewController

- (UITabBarItem *)tabBarItem {
    return [[UITabBarItem alloc] initWithTitle:@"Vote" image:nil selectedImage:nil];
}

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
    return (CGFloat)self.currentCompetition.votes0/self.currentCompetition.totalVotes*100.0f;
}

- (CGFloat)bottomPercentage {
    return (CGFloat)self.currentCompetition.votes1/self.currentCompetition.totalVotes*100.0f;
}

#pragma mark - tap handling
- (void)didTapTop {
    [self.currentCompetition voteFor0];
    [self goToNextCompetition];
}

- (void)didTapBottom {
    [self.currentCompetition voteFor1];
    [self goToNextCompetition];
}

- (IBAction)didTapComment:(id)sender {
    //[self performSegueWithIdentifier:@"voteToComments" sender:self];
}

- (void)goToNextCompetition {
    [self.topImage setImage:nil];
    [self.bottomImage setImage:nil];
    self.currentCompetition = [CompetitionCache next];
    NSLog(@"current competition %@ %@",self.currentCompetition,self.currentCompetition.identifier);
    [self updateView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"voteToComment"]) {
        CommentViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.competition = self.currentCompetition;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self tickUpdate];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
