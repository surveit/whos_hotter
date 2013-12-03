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
#import "FacebookManager.h"
#import "FileManager.h"
#import "NotificationNames.h"
#import "User.h"
#import "Utility.h"

@interface ProfileViewController () <UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *createAccount;

@property (weak, nonatomic) IBOutlet UICollectionView *pastCompetitions;
@property (nonatomic, readwrite, strong) Competition *competitionToSegueTo;

@property (nonatomic, assign) Gender gender;

@end

@implementation ProfileViewController

- (void)dealloc {
    [self unregisterForNotifications];
}

- (IBAction)didTapUploadPhoto:(id)sender {
    [self startLoginFlow];
}

- (IBAction)didTapLoginToFacebook:(id)sender {
    [FacebookManager loginWithCompletionHandler:nil];
}

- (void)updateView {
    if ([[User sharedUser] isLoggedIn]) {
        self.userNameLabel.text = [User username];
        self.profilePicture.image = [[User sharedUser] profileImage];
        [self.pastCompetitions reloadData];
        self.createAccount.hidden = YES;
    }
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
    
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:10];
    titleLabel.text = [Utility percentageStringFromFloat:[competition myPercentage]];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:11];
    [imageView setImage:[competition opponentsImage]];
    
    return cell;
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
    [self performSegueWithIdentifier:@"login" sender:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setupCollectionView];
    
    self.userNameTextField.delegate = self;
    self.createAccount.hidden = [[User sharedUser] isLoggedIn];
    [self updateView];
    
    [self registerForNotifications];
}

@end
