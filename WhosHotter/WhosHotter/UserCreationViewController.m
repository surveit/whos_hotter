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

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (nonatomic, readwrite, assign) Gender gender;

@end

@implementation UserCreationViewController



- (IBAction)didTapFemale:(id)sender {
    self.gender = FEMALE;
    [self updateView];
}

- (IBAction)didTapMale:(id)sender {
    self.gender = MALE;
    [self updateView];
}

- (void)updateView {
    self.maleButton.titleLabel.textColor = self.gender == MALE ? [UIColor blueColor] : [UIColor grayColor];
    self.femaleButton.titleLabel.textColor = self.gender == FEMALE ? [UIColor blueColor] : [UIColor grayColor];
}

- (IBAction)didTapDone:(id)sender {
    if (self.gender == UNKNOWN) {
        [self showAlertToChooseGender];
    } else if (self.usernameTextField.text.length == 0) {
        [self showAlertForInvalidUserName];
    } else {
        [[User sharedUser] createLogin:self.usernameTextField.text password:@"NOPASSWORD"
                                gender:self.gender
                            completion:^(BOOL success, NSError *error) {
                                [self userCreated:success];
                            }];
    }
}

- (void)userCreated:(BOOL)success {
    if (!success) {
        [self showAlertForUserNameTaken];
    } else {
        [[User sharedUser] setProfileImage:self.profileImage];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -- Text field delegate
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
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"Username already exists. Please try a different username"
                               delegate:nil
                      cancelButtonTitle:@"Okay"
                      otherButtonTitles:nil] show];
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
    self.profileImageView.image = self.profileImage;
    self.usernameTextField.delegate = self;
}

@end
