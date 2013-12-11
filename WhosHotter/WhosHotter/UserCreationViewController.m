//
//  UserCreationViewController.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/24/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "UserCreationViewController.h"

#import "EventLogger.h"
#import "FacebookManager.h"
#import "User.h"

@interface UserCreationViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UILabel *enterUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameTakenLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (nonatomic, readwrite, assign) CGPoint originalCenter;

@end

@implementation UserCreationViewController

- (void)dealloc {
    [self unregisterForNotifications];
}

- (IBAction)didTapFemale:(id)sender {
    if (self.gender == UNKNOWN) {
        [self transitionInUsername];
    }
    self.gender = FEMALE;
    [self animateFemaleResponse];
}

- (IBAction)didTapMale:(id)sender {
    if (self.gender == UNKNOWN) {
        [self transitionInUsername];
    }
    self.gender = MALE;
    [self animateMaleResponse];
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


- (void)animateMaleResponse {
    [UIView animateWithDuration:1.0
                     animations:^{
                         [self.maleButton setImage:[self maleButtonImage] forState:UIControlStateNormal];
                         [self.femaleButton setImage:[self blankImage] forState:UIControlStateNormal];
                     }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSValue *bounds = notification.userInfo[UIKeyboardFrameBeginUserInfoKey];
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.view.center = CGPointMake(self.view.center.x, self.view.center.y - bounds.CGRectValue.size.height);
                     }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.view.center = self.originalCenter;
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
    } else if (![User isUserNameValid:self.usernameTextField.text]) {
        [self showAlertForInvalidUserName];
    } else {
        [self.usernameTextField resignFirstResponder];
        self.createButton.userInteractionEnabled = NO;
        [EventLogger logEvent:@"validateUserName"];
        self.spinner.hidden = NO;
        [self.spinner startAnimating];
        [[User sharedUser] createLogin:self.usernameTextField.text password:@"NOPASSWORD"
                                gender:self.gender
                                 image:self.profileImage
                            completion:^(BOOL success, NSError *error) {
                                self.createButton.userInteractionEnabled = YES;
                                [self userCreated:success];
                            }];
    }
}

- (void)userCreated:(BOOL)success {
    self.spinner.hidden = YES;
    [self.spinner stopAnimating];
    if (!success) {
        [EventLogger logEvent:@"userCreateError"];
        [self showAlertForUserNameTaken];
    } else {
        [EventLogger logEvent:@"userCreateSuccess"];
        [[self navigationController] popToRootViewControllerAnimated:YES];
    }
}

#pragma mark -- Text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.usernameTakenLabel.hidden = YES;
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
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)showAlertToChooseGender {
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"You need to pick a gender to continue!"
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil] show];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    self.originalCenter = self.view.center;
    self.spinner.hidden = YES;
    self.usernameTextField.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([FacebookManager gender] == MALE) {
        [self didTapMale:nil];
    } else if ([FacebookManager gender] == FEMALE) {
        [self didTapFemale:nil];
    }
}

@end
