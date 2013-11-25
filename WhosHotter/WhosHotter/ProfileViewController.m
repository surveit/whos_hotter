//
//  ProfileViewController.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/18/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "ProfileViewController.h"

#import "FacebookManager.h"
#import "FileManager.h"
#import "NotificationNames.h"
#import "User.h"

@interface ProfileViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *createAccount;



@property (nonatomic, assign) Gender gender;

@end

@implementation ProfileViewController

- (void)dealloc {
    [self unregisterForNotifications];
}

- (IBAction)didTapUploadPhoto:(id)sender {
    [self startLoginFlow];
}

- (IBAction)didTapComments:(id)sender {
    //[self performSegueWithIdentifier:@"profileToComments" sender:self];
}

- (IBAction)didTapLoginToFacebook:(id)sender {
    [FacebookManager loginWithCompletionHandler:nil];
}

- (void)updateView {
    if ([[User sharedUser] isLoggedIn]) {
        self.userNameLabel.text = [User username];
        self.profilePicture.image = [[User sharedUser] profileImage];
    }
}

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateView)
                                                 name:NOTIFICATION_USER_CREATED
                                               object:nil];
}

- (void)unregisterForNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    self.userNameTextField.delegate = self;
    self.createAccount.hidden = [[User sharedUser] isLoggedIn];
    [self updateView];
    
    [self registerForNotifications];
}

@end
