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
#import "ImageCroppingViewController.h"
#import "User.h"

@interface ProfileViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *createAccount;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImage *uncroppedImage;

@property (nonatomic, assign) Gender gender;

@end

@implementation ProfileViewController

- (IBAction)didTapCreateAccount:(id)sender {
    [[User sharedUser] createLogin:self.userNameTextField.text
                          password:@"somePassword"
                            gender:self.gender
                        completion:^(BOOL success, NSError *error) {
                            if (success) {
                                self.userNameLabel.text = [User username];
                            } else {
                                //show the error
                            }
                        }];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.userNameTextField.delegate = self;
    self.createAccount.hidden = [[User sharedUser] isLoggedIn];
    [self updateView];
}

#pragma mark -- User creation flow
- (void)startLoginFlow {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        /*
         The user wants to use the camera interface. Set up our custom overlay view for the camera.
         */
        imagePickerController.showsCameraControls = NO;
        
    }
    
    self.imagePickerController = imagePickerController;
    
    [self presentViewController:self.imagePickerController
                                          animated:YES
                                        completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.uncroppedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.imagePickerController dismissViewControllerAnimated:YES
                                                   completion:^{
                                                       [self performSegueWithIdentifier:@"cropImage"
                                                                                 sender:self];
                                                   }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"cropImage"]) {
        UINavigationController *viewController = [segue destinationViewController];
        ImageCroppingViewController *imageCroppingViewController = (ImageCroppingViewController *)[viewController topViewController];
        imageCroppingViewController.profileImage = self.uncroppedImage;
    }
}

@end
