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

#define kBaseHeight 12
#define kCellSpacing 4

@interface CommentViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *commentTextField;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImageView;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UITextField *commentInputTextField;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;
@property (nonatomic, readwrite, assign) BOOL isPriorityView;

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
        [self showAlertViewForMessage:@"Can't post an empty comment!"];
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

- (void)updateView {
    [self.bottomImageView setImage:self.competition.bottomImage];
    [self.topImageView setImage:self.competition.topImage];
    [self.commentsTableView reloadData];
}

- (IBAction)didTapClose:(id)sender {
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

#pragma mark - uitextfielddelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSString *error = [Comment isValidCommentText:textField.text];
    if (error) {
        [self showAlertViewForMessage:error];
    } else {
        [textField resignFirstResponder];
    }
    return !error;
}

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
    CGSize size = [description sizeWithAttributes:@{NSFontAttributeName: [self commentFont]}];

    NSMutableAttributedString *coloredText = [[NSMutableAttributedString alloc] initWithString:description];
    [coloredText addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range: NSMakeRange(0, username.length + 5)];

    cell.textLabel.font = font;
    cell.textLabel.attributedText = coloredText;
    cell.textLabel.numberOfLines = ceil(size.width / 300);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *description = [self.competition.comments[indexPath.row] description];
    CGSize size = [description sizeWithAttributes:@{NSFontAttributeName: [self commentFont]}];
    return ceil(size.width / 300) * kBaseHeight + kCellSpacing;
}

- (UIFont *)commentFont {
    return [UIFont fontWithName:@"HelveticaNeue" size:10];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.commentsTableView.dataSource = self;
    self.commentsTableView.delegate = self;
    [self.commentsTableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"comment"];
    self.commentInputTextField.delegate = self;
    self.commentTextField.userInteractionEnabled = NO;
    [self updateView];
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.isPriorityView = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isPriorityView = NO;
}

@end
