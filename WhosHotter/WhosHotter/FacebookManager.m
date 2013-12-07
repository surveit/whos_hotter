//
//  FacebookManager.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/23/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "FacebookManager.h"

#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "User.h"

FacebookManager *sharedInstance = nil;

@interface FacebookManager () <NSURLConnectionDataDelegate>

@property (nonatomic, readwrite, strong) NSString *gender;
@property (nonatomic, readwrite, strong) NSString *facebookId;
@property (nonatomic, readwrite, strong) NSURL *pictureURL;

@property (nonatomic, readwrite, strong) NSMutableData *imageData;
@property (nonatomic, readwrite, strong) UIImage *image;

@property (nonatomic, readwrite, copy) CompletionHandler handler;

@end

@implementation FacebookManager

+ (FacebookManager *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[FacebookManager alloc] init];
    }
    return sharedInstance;
}

+ (void)loginWithCompletionHandler:(CompletionHandler)handler {
    // The permissions requested from the user
    NSArray *permissionsArray = @[@"user_about_me"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils initializeFacebook];
    
    if ([[User sharedUser] isLoggedIn]) {
        [PFFacebookUtils linkUser:[PFUser user]
                      permissions:permissionsArray
                            block:^(BOOL succeeded, NSError *error) {
                                if (succeeded) {
                                    [self getFacebookInformationWithCompletionHandler:handler];
                                }
                            }];
    } else {
        [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
            [self getFacebookInformationWithCompletionHandler:handler];
        }];
    }
}

+ (BOOL)isLoggedInToFacebook {
    return [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
}

+ (void)getFacebookInformationWithCompletionHandler:(CompletionHandler)handler {
    [[self sharedInstance] getFacebookInformationWithCompletionHandler:handler];
}

+ (UIImage *)profileImage {
    return [[self sharedInstance] image];
}

+ (Gender)gender {
    return [[self sharedInstance] gender] ? [[[self sharedInstance] gender] isEqualToString:@"male"] ? MALE : FEMALE : UNKNOWN;
}

- (void)getFacebookInformationWithCompletionHandler:(CompletionHandler)handler {
    FBRequest *request = [FBRequest requestForMe];
    
    self.handler = handler;
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            self.facebookId = userData[@"id"];
            self.gender = userData[@"gender"];
            
            self.pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", self.facebookId]];
            
            NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:self.pictureURL
                                                                      cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                  timeoutInterval:2.0f];
            NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
            [urlConnection start];
        } else {
            if (self.handler) {
                self.handler(NO,error);
                self.handler = nil;
            }
        }
    }];
}

- (NSMutableData *)imageData {
    if (!_imageData) {
        _imageData = [NSMutableData data];
    }
    return _imageData;
}

// Called every time a chunk of the data is received
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.imageData appendData:data]; // Build the image
}

// Called when the entire image is finished downloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.image = [UIImage imageWithData:self.imageData];
    if (self.handler) {
        self.handler(YES,nil);
        self.handler = nil;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (self.handler) {
        self.handler(NO,error);
        self.handler = nil;
    }
}

@end
