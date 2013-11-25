//
//  UserCreationViewController.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/24/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "UserCreationViewController.h"

#import "User.h"

@interface UserCreationViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (nonatomic, readwrite, assign) Gender gender;


@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UILabel *enterUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameTakenLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation UserCreationViewController



- (IBAction)didTapFemale:(id)sender {
    self.gender = FEMALE;
    [self transitionInUsername];
    [self animateFemaleResponse];
}

- (IBAction)didTapMale:(id)sender {
    self.gender = MALE;
    [self transitionInUsername];
    [self animateMaleResponse];
}

- (void)animateMaleResponse {
    [UIView animateWithDuration:1.0
                     animations:^{
                         [self.maleButton setImage:[self maleButtonImage] forState:UIControlStateNormal];
                         [self.femaleButton setImage:[self blankImage] forState:UIControlStateNormal];
                     }];
}

- (void)animateFemaleResponse {
    [UIView animateWithDuration:1.0
                     animations:^{
                         [self.femaleButton setImage:[self femaleButtonImage] forState:UIControlStateNormal];
                         [self.maleButton setImage:[self blankImage] forState:UIControlStateNormal];
                     }];
}

- (UIImage *)blankImage {
    return [UIImage imageNamed:@"Disabled Gender@2x"];
}

- (UIImage *)maleButtonImage {
    return [UIImage imageNamed:@"Male button@2x"];
}

- (UIImage *)femaleButtonImage {
    return [UIImage imageNamed:@"Female button@2x"];
}

- (void)transitionInUsername {
    self.enterUsernameLabel.hidden = NO;
    self.usernameTextField.hidden = NO;
    self.createButton.hidden = NO;
    
    self.enterUsernameLabel.alpha = 0;
    self.usernameTextField.alpha = 0;
    self.createButton.alpha = 0;
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.enterUsernameLabel.alpha = 1.0;
                         self.usernameTextField.alpha = 1.0;
                         self.createButton.alpha = 1.0;
                     }];
}

- (IBAction)didTapDone:(id)sender {
    if (self.gender == UNKNOWN) {
        [self showAlertToChooseGender];
    } else if (self.usernameTextField.text.length == 0) {
        [self showAlertForInvalidUserName];
    } else {
        self.spinner.hidden = NO;
        [self.spinner startAnimating];
        [[User sharedUser] createLogin:self.usernameTextField.text password:@"NOPASSWORD"
                                gender:self.gender
                            completion:^(BOOL success, NSError *error) {
                                [self userCreated:success];
                            }];
    }
}

- (void)userCreated:(BOOL)success {
    self.spinner.hidden = YES;
    [self.spinner stopAnimating];
    if (!success) {
        [self showAlertForUserNameTaken];
    } else {
        [[User sharedUser] setProfileImage:self.profileImage];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -- Text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.usernameTakenLabel.hidden = YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([User isUserNameValid:textField.text]) {
        [textField resignFirstResponder];
        return YES;
    } else {
        [self showAlertForInvalidUserName];
        return NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([User isUserNameValid:textField.text]) {
        [textField resignFirstResponder];
        return YES;
    } else {
        [self showAlertForInvalidUserName];
        return NO;
    }
}

#pragma mark -- Error handling
- (void)showAlertForUserNameTaken {
    self.usernameTakenLabel.hidden = NO;
}

- (void)showAlertForInvalidUserName {
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"Please choose a user name with no spaces, between 4 and 20 characters."
                               delegate:nil
                      cancelButtonTitle:@"Okay"
                      otherButtonTitles:nil] show];
}

- (void)showAlertToChooseGender {
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"You need to pick a gender to continue!"
                               delegate:nil
                      cancelButtonTitle:@"Okay"
                      otherButtonTitles:nil] show];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.spinner.hidden = YES;
    self.usernameTextField.delegate = self;
}

@end
