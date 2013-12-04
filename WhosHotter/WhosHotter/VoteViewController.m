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

@property (weak, nonatomic) IBOutlet UIImageView *greenSqure;
@property (weak, nonatomic) IBOutlet UILabel *percentageLabel;

@property (nonatomic, readwrite, strong) Competition *currentCompetition;
@property (nonatomic, readwrite, strong) Competition *previousCompetition;
@property (weak, nonatomic) IBOutlet TappableImageView *topImage;
@property (weak, nonatomic) IBOutlet TappableImageView *bottomImage;
@property (weak, nonatomic) IBOutlet UIImageView *frameImage;
@property (weak, nonatomic) IBOutlet UIImageView *bottomFire;
@property (weak, nonatomic) IBOutlet UIImageView *topFire;

@property (nonatomic, readwrite, strong) TappableImageView *topImageView;
@property (nonatomic, readwrite, strong) TappableImageView *bottomImageView;
@property (nonatomic, readwrite, strong) TappableImageView *winnerImageView;
@property (nonatomic, readwrite, assign) CGRect topFrame;
@property (nonatomic, readwrite, assign) CGRect bottomFrame;
@end

@implementation VoteViewController

- (void)updateView {
    [self.topImageView setImage:self.currentCompetition.topImage];
    [self.bottomImageView setImage:self.currentCompetition.bottomImage];
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
    if (self.currentCompetition) {
        if ([self.currentCompetition canAffrdEnergy]) {
            [self.currentCompetition voteFor0];
            __weak VoteViewController *weakSelf = self;
            CGFloat percentage = [self topPercentage];
            [self addFire:self.topFire completionHandler:^(BOOL finished) {
                [weakSelf animateAway:weakSelf.bottomImageView];
                [weakSelf animateWin:weakSelf.topImageView percentage:percentage];
            }];
        } else {
            [self showOutOfEnergyPopup];
        }
    }
}

- (void)didTapBottom {
    if (self.currentCompetition) {
        if ([self.currentCompetition canAffrdEnergy]) {
            [self.currentCompetition voteFor1];
            __weak VoteViewController *weakSelf = self;
            CGFloat percentage = [self bottomPercentage];
            [self addFire:self.bottomFire completionHandler:^(BOOL finished) {
                [weakSelf animateAway:weakSelf.topImageView];
                [weakSelf animateWin:weakSelf.bottomImageView percentage:percentage];
            }];
        } else {
            [self showOutOfEnergyPopup];
        }
    }
}

- (void)addFire:(UIImageView *)imageView completionHandler:(AnimationHandler)handler {
    imageView.hidden = NO;
    imageView.alpha = 0;
    [UIView animateWithDuration:0.15
                     animations:^{
                         imageView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.45
                                          animations:^{
                                              imageView.alpha = 0;
                                          }
                          completion:^(BOOL finished) {
                              if (handler) {
                                  handler(finished);
                              }
                          }];
                     }];
}

- (void)animateWin:(TappableImageView *)imageView percentage:(CGFloat)percentage {
    [self.winnerImageView removeFromSuperview];
    self.winnerImageView = imageView;
    
    __weak VoteViewController *weakSelf = self;
    [imageView setTapHandler:^(){
        [weakSelf performSegueWithIdentifier:@"voteToComments" sender:weakSelf];
    }];
    [self performSelector:@selector(didVote) withObject:nil afterDelay:0.3];
    [UIView animateWithDuration:0.5
                     animations:^{
                         imageView.frame = self.frameImage.frame;
                         self.frameImage.alpha = 1.0;
                         self.greenSqure.alpha = 1.0;
                         self.percentageLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         self.percentageLabel.text = [Utility percentageStringFromFloat:percentage];
                     }];
}

- (void)animateAway:(TappableImageView *)imageView {
    [UIView animateWithDuration:0.4
                     animations:^{
                         imageView.tintColor = [UIColor blackColor];
                         CGPoint newCenter = [Utility addPoint:[Utility multiplyPoint:imageView.center scalar:4.0]
                                                            to:[Utility multiplyPoint:self.view.center scalar:-3.0]];
                         imageView.center = newCenter;
                     }
                     completion:^(BOOL finished) {
                         [imageView removeFromSuperview];
                     }];
}

- (void)didVote {
    [self goToNextCompetition];
    [self updateEnergy];
}

- (void)goToNextCompetition {
    [self createCompetitionView];
    self.previousCompetition = self.currentCompetition;
    self.currentCompetition = [CompetitionCache next];
    NSLog(@"current competition %@ %@",self.currentCompetition,self.currentCompetition.identifier);
    [self updateView];
}

- (void)createCompetitionView {
    self.topImageView = [[TappableImageView alloc] initWithFrame:self.topFrame];
    self.bottomImageView = [[TappableImageView alloc] initWithFrame:self.bottomFrame];
    self.topImageView.contentMode = self.topImage.contentMode;
    self.bottomImageView.contentMode = self.bottomImage.contentMode;
    self.topImageView.clipsToBounds = YES;
    self.bottomImageView.clipsToBounds = YES;
    self.topImageView.userInteractionEnabled = YES;
    self.bottomImageView.userInteractionEnabled = YES;
    [self.view insertSubview:self.topImageView belowSubview:self.winnerImageView ?: self.frameImage];
    [self.view insertSubview:self.bottomImageView belowSubview:self.winnerImageView ?: self.frameImage];
    
    /*
    self.topImageView.center = CGPointMake(self.topImageView.center.x + 400, self.topImageView.center.y);
    self.bottomImageView.center = CGPointMake(self.bottomImageView.center.x - 400, self.bottomImageView.center.y);
    [UIView animateWithDuration:0.6
                     animations:^{
                         self.topImageView.frame = self.topFrame;
                         self.bottomImageView.frame = self.bottomFrame;
                     }];
     */
    
    self.topImageView.alpha = 0.0;
    self.bottomImageView.alpha = 0.0;
    [UIView animateWithDuration:0.6
                     animations:^{
                         self.topImageView.alpha = 1.0;
                         self.bottomImageView.alpha = 1.0;
                     }];
    
    __weak VoteViewController *weakSelf = self;
    [self.topImageView setTapHandler:^(){
        [weakSelf didTapTop];
    }];
    [self.bottomImageView setTapHandler:^(){
        [weakSelf didTapBottom];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"voteToComments"]) {
        CommentViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.competition = self.previousCompetition;
    }
}

- (void)updateEnergy {
    self.energyLabel.text = [NSString stringWithFormat:@"%ld",[[User sharedUser] energy]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.topFrame = self.topImage.frame;
    self.bottomFrame = self.bottomImage.frame;
    
    self.greenSqure.alpha = 0;
    self.frameImage.alpha = 0;
    self.percentageLabel.alpha = 0;
    
    [self tickUpdate];
    [self updateEnergy];
    
    [self createCompetitionView];
    [self updateView];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"B" style:UIBarButtonItemStylePlain target:nil action:nil];
}

@end
