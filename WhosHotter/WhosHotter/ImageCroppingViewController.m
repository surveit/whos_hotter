//
//  ImageCroppingViewController.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/24/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "ImageCroppingViewController.h"

#import "UserCreationViewController.h"

@interface ImageCroppingViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, readwrite, strong) UIImage *croppedImage;

@end

@implementation ImageCroppingViewController

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.imageView.image = self.profileImage;
    self.imageView.frame = CGRectMake(0, 0, self.profileImage.size.width, self.profileImage.size.height);
    
    [self.scrollView setContentSize:self.profileImage.size];
    [self.scrollView setMaximumZoomScale:1.0];
    [self.scrollView setMinimumZoomScale:[self minZoomScale]];
    self.scrollView.zoomScale = [self minZoomScale];
    
    [self centerOnImage];
}

- (CGFloat)minZoomScale {
    return self.scrollView.frame.size.width / MIN(self.profileImage.size.width,self.profileImage.size.height);
}

- (void)centerOnImage {
    CGSize imageSize = self.profileImage.size;
    CGSize scrollViewSize = self.scrollView.frame.size;
    self.scrollView.contentOffset = CGPointMake(imageSize.width / 2.0 * self.scrollView.zoomScale - scrollViewSize.width / 2.0,
                                                imageSize.height / 2.0 * self.scrollView.zoomScale - scrollViewSize.height / 2.0);
}

- (IBAction)didTapDone:(id)sender {
    CGSize imageSize = CGSizeMake(self.scrollView.frame.size.width/self.scrollView.zoomScale,
                                  self.scrollView.frame.size.height/self.scrollView.zoomScale);
    
    CGRect clippedRect  = CGRectMake(self.scrollView.contentOffset.x / self.scrollView.zoomScale,
                                     self.scrollView.contentOffset.y / self.scrollView.zoomScale,
                                     imageSize.width,
                                     imageSize.height);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self.profileImage CGImage], clippedRect);
    self.croppedImage = [UIImage imageWithCGImage:imageRef scale:self.scrollView.zoomScale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    [self performSegueWithIdentifier:@"imageCropperToUserCreation" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"imageCropperToUserCreation"]) {
        UserCreationViewController *viewController = [segue destinationViewController];
        viewController.profileImage = self.croppedImage;
    }
}


@end
