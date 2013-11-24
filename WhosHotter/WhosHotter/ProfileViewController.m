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
#import "User.h"

@interface ProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (nonatomic, strong) UIImagePickerController *imagePickerController;
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
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.imagePickerController dismissViewControllerAnimated:YES
                                                   completion:nil];
    [[User sharedUser] setProfileImage:image];
    
    [self.profilePicture setImage:image];
    
    [[User sharedUser] submitForCompetition:^(NSArray *objects, NSError *error) {
        NSLog(@"The competitions: %@",objects);
    }];
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
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (IBAction)didTapComments:(id)sender {
    //[self performSegueWithIdentifier:@"profileToComments" sender:self];
}

- (IBAction)didTapLoginToFacebook:(id)sender {
    [FacebookManager login];
}

- (void)updateView {
    self.userNameLabel.text = [User username];
    self.profilePicture.image = [[User sharedUser] profileImage];
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
    [self updateView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
