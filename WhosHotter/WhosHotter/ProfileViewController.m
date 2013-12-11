//
//  ProfileViewController.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/18/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "ProfileViewController.h"

#import "CommentViewController.h"
#import "Competition.h"
#import "EventLogger.h"
#import "FacebookManager.h"
#import "FileManager.h"
#import "NotificationNames.h"
#import "User.h"
#import "ImageCroppingViewController.h"
#import "TappableImageView.h"
#import "Utility.h"

@interface ProfileViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet TappableImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *createAccount;
@property (weak, nonatomic) IBOutlet UILabel *flamePointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *createAccountLabel;

@property (weak, nonatomic) IBOutlet UIButton *fbLoginButton;
@property (weak, nonatomic) IBOutlet UIButton *fbShareButton;

@property (weak, nonatomic) IBOutlet UIButton *cheatButton;
@property (weak, nonatomic) IBOutlet UICollectionView *pastCompetitions;
@property (nonatomic, readwrite, strong) Competition *competitionToSegueTo;
@property (weak, nonatomic) IBOutlet UIImageView *galleryView;

@property (nonatomic, readwrite, strong) NSMutableSet *cellsToRefresh;
@property (weak, nonatomic) IBOutlet UILabel *findingMatchLabel;

@property (nonatomic, assign) Gender gender;
@property (weak, nonatomic) IBOutlet UIView *facebookLoadingView;

@end

@implementation ProfileViewController

- (void)dealloc {
    [self unregisterForNotifications];
}

- (IBAction)didTapUploadPhoto:(id)sender {
    [self startLoginFlow];
}

- (IBAction)didTapLoginToFacebook:(id)sender {
    self.fbLoginButton.userInteractionEnabled = NO;
    self.facebookLoadingView.hidden = NO;
    if ([[User sharedUser] isLoggedIn]) {
        [FacebookManager loginWithCompletionHandler:^(BOOL success, NSError *error) {
            if (success) {
                [self updateView];
            }
            self.facebookLoadingView.hidden = YES;
            self.fbLoginButton.userInteractionEnabled = YES;
        }];
    } else {
        [FacebookManager loginWithCompletionHandler:^(BOOL success, NSError *error) {
            if (success) {
                [self performSegueWithIdentifier:@"profileToImageCrop" sender:self];
            }
            self.facebookLoadingView.hidden = YES;
            self.fbLoginButton.userInteractionEnabled = YES;
        }];
    }
}

- (IBAction)didTapShareToFacebook:(id)sender {
}

- (void)didTapProfileImage {
    [self startLoginFlow];
}

- (void)updateView {
    if ([[User sharedUser] isLoggedIn]) {
        self.userNameLabel.text = [User username];
        self.profilePicture.image = [[User sharedUser] profileImage];
        [self.pastCompetitions reloadData];
        self.createAccount.hidden = YES;
        self.createAccountLabel.hidden = YES;
        self.galleryView.hidden = YES;
        self.findingMatchLabel.hidden = [[[User sharedUser] pastCompetitions] count] > 0;
    }
    
    self.flamePointsLabel.text = @([[User sharedUser] flamePoints]).description;
    BOOL isLoggedInToFacebook = [FacebookManager isLoggedInToFacebook] && [[User sharedUser] isLoggedIn];
    self.fbLoginButton.hidden = isLoggedInToFacebook;
    self.fbShareButton.hidden = !isLoggedInToFacebook;
}

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateView)
                                                 name:NOTIFICATION_USER_CREATED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateView)
                                                 name:NOTIFICATION_COMPETITIONS_UPDATED
                                               object:nil];
}

- (void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -- collection view data source
- (void)setupCollectionView {
    UINib *cellNib = [UINib nibWithNibName:@"CompetitionCellView" bundle:nil];
    [self.pastCompetitions registerNib:cellNib forCellWithReuseIdentifier:@"cell"];
    self.pastCompetitions.dataSource = self;
    self.pastCompetitions.delegate = self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[User sharedUser] pastCompetitions] count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Competition *competition = [[User sharedUser] pastCompetitions][indexPath.row];
    
    static NSString *cellIdentifier = @"cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    UILabel *percentageLabel = (UILabel *)[cell viewWithTag:14];
    percentageLabel.text = [Utility percentageStringFromFloat:[competition myRatio]];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:11];
    [imageView setImage:[competition opponentsImage]];
    
    UIView *redBackground = [cell viewWithTag:12];
    UIView *greenBackground = [cell viewWithTag:13];
    UIView *largeGreenBackground = [cell viewWithTag:15];
    UILabel *timeLeft = (UILabel *)[cell viewWithTag:16];
    
    redBackground.hidden = [competition timeUntilExpiration] > 0 || [competition myRatio] > .5;
    greenBackground.hidden = [competition timeUntilExpiration] > 0 || [competition myRatio] <= .5;
    largeGreenBackground.hidden = [competition timeUntilExpiration] <= 0;
    timeLeft.hidden = [competition timeUntilExpiration] <= 0;
    percentageLabel.hidden = [competition timeUntilExpiration] > 0;
    
    timeLeft.text = [Utility getHHMMSSFromSeconds:[competition timeUntilExpiration]];
    
    if ([competition timeUntilExpiration] > 0) {
        [self.cellsToRefresh addObject:cell];
    } else {
        [self.cellsToRefresh removeObject:cell];
    }
    
    return cell;
}

- (NSMutableSet *)cellsToRefresh {
    if (!_cellsToRefresh) {
        _cellsToRefresh = [NSMutableSet set];
    }
    return _cellsToRefresh;
}

- (void)refreshText {
    BOOL viewNeedsUpdate = NO;
    
    for (UICollectionViewCell *cell in self.cellsToRefresh) {
        UILabel *timeLeft = (UILabel *)[cell viewWithTag:16];
        NSInteger index = [self.pastCompetitions indexPathForCell:cell].row;
        Competition *competition = [[User sharedUser] pastCompetitions][index];
        timeLeft.text = [Utility getHHMMSSFromSeconds:competition.timeUntilExpiration];
        viewNeedsUpdate |= competition.timeUntilExpiration < 0;
    }
    
    if (viewNeedsUpdate) {
        [self updateView];
    }
    
    [self performSelector:@selector(refreshText) withObject:nil afterDelay:1.0];
}

#pragma mark -- collection view delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Competition *competition = [[User sharedUser] pastCompetitions][indexPath.row];
    self.competitionToSegueTo = competition;
    
    [self performSegueWithIdentifier:@"profileToComments" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"profileToComments"]) {
        CommentViewController *viewController = (CommentViewController *)[segue destinationViewController];
        [viewController setCompetition:self.competitionToSegueTo];
    } else if ([segue.identifier isEqualToString:@"profileToImageCrop"]) {
        ImageCroppingViewController *viewController = (ImageCroppingViewController *)[segue destinationViewController];
        [viewController setProfileImage:[FacebookManager profileImage]];
    }
}


#pragma mark -- Text field delegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (void)startLoginFlow {
    [EventLogger logEvent:@"tappedUploadPhoto"];
    [self performSegueWithIdentifier:@"login" sender:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateView];
    [self refreshText];
}

- (void)viewDidDisappear:(BOOL)animated {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
 
#ifdef DEBUG
    self.cheatButton.hidden = NO;
#else
    self.cheatButton.hidden = YES;
#endif
    
    [self setupCollectionView];
    
    self.userNameTextField.delegate = self;
    self.profilePicture.tapHandler = ^(void) {
        [self didTapProfileImage];
    };
    self.profilePicture.userInteractionEnabled = YES;
    [self updateView];
    
    [self registerForNotifications];
}

@end
