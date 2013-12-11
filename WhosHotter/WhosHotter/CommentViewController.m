//
//  CommentViewController.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/18/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "CommentViewController.h"

#import "Comment.h"
#import "Competition.h"
#import "HotterFacebookManager.h"
#import "Report.h"

#define kBaseHeight 16
#define kCellSpacing 4

@interface CommentViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *commentTextField;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImageView;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UITextField *commentInputTextField;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;
@property (nonatomic, readwrite, assign) BOOL isPriorityView;
@property (weak, nonatomic) IBOutlet UILabel *timeLeftLabel;

@property (weak, nonatomic) IBOutlet UIImageView *leftRedSquare;
@property (weak, nonatomic) IBOutlet UIImageView *leftGreenSquare;
@property (weak, nonatomic) IBOutlet UIImageView *rightGreenSquare;
@property (weak, nonatomic) IBOutlet UIImageView *rightRedSquare;
@property (weak, nonatomic) IBOutlet UILabel *leftPercentage;
@property (weak, nonatomic) IBOutlet UILabel *rightPercentage;
@property (weak, nonatomic) IBOutlet UILabel *noCommentsLabel;

@property (weak, nonatomic) IBOutlet UIButton *fbShareButton;

@end

@implementation CommentViewController

- (void)dealloc {
    [self unregisterForNotifications];
}

- (void)postNewComment {
    if (!self.isPriorityView) {
        return;
    }
    
    if (self.commentInputTextField.text.length == 0) {
        return;
    }
    
    NSString *competitionIdentifier = self.competition.identifier;
    Comment *comment = [Comment postCommentWithCompetitionId:competitionIdentifier
                                                        text:self.commentInputTextField.text];
    [self.competition addCommentToCache:comment];
    [self updateView];
    self.commentInputTextField.text = @"";
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
}

- (void)updateTimer {
    if (self.competition.timeUntilExpiration > 0) {
        self.timeLeftLabel.text = [NSString stringWithFormat:@"LIVE %@",[Utility getHHMMSSFromSeconds:self.competition.timeUntilExpiration]];
        [self performSelector:@selector(updateTimer) withObject:nil afterDelay:1.0];
    } else {
        self.timeLeftLabel.text = @"COMPLETE 00:00:00";
    }
}

- (void)updateView {
    [self.bottomImageView setImage:self.competition.bottomImage];
    [self.topImageView setImage:self.competition.topImage];
    [self.commentsTableView reloadData];
    
    CGFloat leftPercentage = [self leftPercentageValue];
    CGFloat rightPercentage = [self rightPercentageValue];
    
    self.leftPercentage.text = [Utility percentageStringFromFloat:leftPercentage];
    self.rightPercentage.text = [Utility percentageStringFromFloat:rightPercentage];
    
    self.leftGreenSquare.hidden = leftPercentage < 50.0f;
    self.leftRedSquare.hidden = leftPercentage >= 50.0f;
    
    self.rightGreenSquare.hidden = rightPercentage < 50.0f;
    self.rightRedSquare.hidden = rightPercentage >= 50.0f;
    self.noCommentsLabel.hidden = self.competition.comments.count > 0;
    
    self.fbShareButton.hidden = ![FacebookManager isLoggedInToFacebook];
}

- (CGFloat)leftPercentageValue {
    if (self.competition.totalVotes == 0) {
        return 50.0;
    }
    return (CGFloat)self.competition.votes0/self.competition.totalVotes*100.0f;
}

- (CGFloat)rightPercentageValue {
    if (self.competition.totalVotes == 0) {
        return 50.0;
    }
    return (CGFloat)self.competition.votes1/self.competition.totalVotes*100.0f;
}


- (IBAction)didTapShare:(id)sender {
    if (self.competition.isMyCompetition) {
        //do something
    } else {
        [HotterFacebookManager postPhoto:self.competition.chosenImage
                                username:self.competition.chosenUsername];
    }
}

- (IBAction)didTapReportButton:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Report"
                                                        message:@"Report as offensive?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK",nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [Report reportWithCompetition:self.competition];
    }
}

#pragma mark - uitextfielddelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *error = [Comment isValidCommentText:textField.text];
    if (error) {
        [self showAlertViewForMessage:error];
    } else {
        [textField resignFirstResponder];
    }
    return !error;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    [self postNewComment];
}

#pragma mark - helper function
- (void)showAlertViewForMessage:(NSString *)message {
    if (self.isPriorityView) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.competition.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"comment"];
    
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, 320, 22);
    UIFont *font = [self commentFont];
    NSString *username = [self.competition.comments[indexPath.row] username];
    NSString *description = [self.competition.comments[indexPath.row] description];

    NSMutableAttributedString *coloredText = [[NSMutableAttributedString alloc] initWithString:description];
    [coloredText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range: NSMakeRange(0, username.length)];

    cell.textLabel.font = font;
    cell.textLabel.attributedText = coloredText;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *description = [self.competition.comments[indexPath.row] description];
    CGSize size = [description sizeWithAttributes:@{NSFontAttributeName: [self commentFont]}];
    return ceil(size.width / 290) * kBaseHeight + kCellSpacing;
}

- (UIFont *)commentFont {
    return [UIFont fontWithName:@"HelveticaNeue" size:14];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.commentsTableView.dataSource = self;
    self.commentsTableView.delegate = self;
    [self.commentsTableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"comment"];
    self.commentInputTextField.delegate = self;
    self.commentsTableView.contentInset = UIEdgeInsetsMake(0, 10.0, 0, 10.0);
    self.commentTextField.userInteractionEnabled = NO;
    [self updateView];
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isPriorityView = YES;
    [self updateTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isPriorityView = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
