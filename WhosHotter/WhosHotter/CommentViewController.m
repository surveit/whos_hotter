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

@interface CommentViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextView *commentTextField;
@property (weak, nonatomic) IBOutlet UIImageView *bottomImageView;
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UITextField *commentInputTextField;

@end

@implementation CommentViewController

- (void)postNewComment {
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

- (void)updateView {
    [self.bottomImageView setImage:self.competition.bottomImage];
    [self.topImageView setImage:self.competition.topImage];
    self.commentTextField.text = self.competition.comments.description;
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.commentInputTextField.delegate = self;
    [self updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
