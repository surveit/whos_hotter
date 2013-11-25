//
//  ImagePickerViewController.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/24/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "ImagePickerViewController.h"

#import "ImageCroppingViewController.h"
#import "StatusBarFreeImagePickerViewController.h"

@interface ImagePickerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) StatusBarFreeImagePickerViewController *imagePickerController;
@property (nonatomic, strong) UIImage *uncroppedImage;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@end

@implementation ImagePickerViewController

#pragma mark -- User creation flow
- (void)viewDidLoad {
    [super viewDidLoad];
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    StatusBarFreeImagePickerViewController *imagePickerController = [[StatusBarFreeImagePickerViewController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.modalPresentationCapturesStatusBarAppearance = YES;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self.mainView addSubview:self.imagePickerController.view];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.uncroppedImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self performSegueWithIdentifier:@"cropImage" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"cropImage"]) {
        ImageCroppingViewController *viewController = [segue destinationViewController];
        viewController.profileImage = self.uncroppedImage;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
