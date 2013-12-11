//
//  HotterFacebookManager.m
//  WhosHotter
//
//  Created by Shuhan Bao on 12/10/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "HotterFacebookManager.h"

#import "Competition.h"
#import "OpenGraphProtocols.h"
#import "TimeManager.h"

@interface FacebookManager (HotterFacebookManager)

+ (instancetype)sharedInstance;

@end

@interface HotterFacebookManager () <UIAlertViewDelegate>

@property (nonatomic, readwrite, strong) Competition *competitionToShare;

@end

@implementation HotterFacebookManager

+ (id<OGPerson>)userForUsername:(NSString*)username
{
    // This URL is specific to this sample, and can be used to
    // create arbitrary OG objects for this app; your OG objects
    // will have URLs hosted by your server.
    NSString *format =
    @"http://hotterapp.surveit.com/opengraph.php?"
    @"fb:app_id=1417735615126992&og:type=%@&"
    @"og:title=%@&og:description=%%22%@%%22&"
    @"body=%@";
    
    // We create an FBGraphObject object, but we can treat it as
    // an SCOGMeal with typed properties, etc. See <FacebookSDK/FBGraphObject.h>
    // for more details.
    id<OGPerson> result = (id<OGPerson>)[FBGraphObject graphObject];
    
    // Give it a URL that will echo back the name of the meal as its title,
    // description, and body.
    result.url = [NSString stringWithFormat:format,
                  @"hotterapp:person", username, username, username];
    
    return result;
}

+ (void)shareCompetition:(Competition *)competition {
    UIAlertView *share = [[UIAlertView alloc] initWithTitle:@"Share?"
                                                    message:@"Share this competition on Facebook?"
                                                   delegate:[self sharedInstance]
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    [share show];
    [[self sharedInstance] setCompetitionToShare:competition];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (self.competitionToShare.isMyCompetition) {
            [HotterFacebookManager postMyCompetitionAgainst:self.competitionToShare.opponentsImage
                                                   username:self.competitionToShare.opponentsUsername
                                                   timeLeft:self.competitionToShare.timeUntilExpiration];
        } else {
            [HotterFacebookManager postPhoto:self.competitionToShare.chosenImage
                                    username:self.competitionToShare.chosenUsername];
        }
    }
}

+ (void)getPublishPermissions:(CompletionHandler)handler {
    if (![[[FBSession activeSession] permissions] containsObject:@"publish_actions"]) {
        [[FBSession activeSession] requestNewPublishPermissions:@[@"publish_actions"]
                                                defaultAudience:FBSessionDefaultAudienceEveryone
                                              completionHandler:^(FBSession *session, NSError *error) {
                                                  if (handler) {
                                                      handler(error == nil,error);
                                                  }
                                              }];
    } else if (handler) {
        handler (YES, nil);
    }
}

+ (void)postMyCompetitionAgainst:(UIImage *)image
                        username:(NSString *)username
                        timeLeft:(NSInteger)timeLeft {
    [self getPublishPermissions:^(BOOL success, NSError *error) {
        if (success) {
            FBRequestConnection *connection = [[FBRequestConnection alloc] init];
            
            // First request uploads the photo.
            FBRequest *request1 = [FBRequest requestForUploadPhoto:image];
            [connection addRequest:request1
                 completionHandler:
             ^(FBRequestConnection *connection, id result, NSError *error) {
                 if (!error) {
                 }
             }
                    batchEntryName:@"photopost"
             ];
            
            // Second request retrieves photo information for just-created
            // photo so we can grab its source.
            FBRequest *request2 = [FBRequest
                                   requestForGraphPath:@"{result=photopost:$.id}"];
            [connection addRequest:request2
                 completionHandler:
             ^(FBRequestConnection *connection, id result, NSError *error) {
                 if (!error &&
                     result) {
                     NSString *source = [result objectForKey:@"source"];
                     [self postOpenGraphActionWithPhotoURL:source
                                                  username:username
                                                  timeLeft:timeLeft];
                 }
             }
             ];
            
            [connection start];
        }
    }];
}

+ (void)postPhoto:(UIImage *)image
         username:(NSString *)username
{
    [self getPublishPermissions:^(BOOL success, NSError *error) {
        if (success) {
            FBRequestConnection *connection = [[FBRequestConnection alloc] init];
            
            // First request uploads the photo.
            FBRequest *request1 = [FBRequest requestForUploadPhoto:image];
            [connection addRequest:request1
                 completionHandler:
             ^(FBRequestConnection *connection, id result, NSError *error) {
                 if (!error) {
                 }
             }
                    batchEntryName:@"photopost"
             ];
            
            // Second request retrieves photo information for just-created
            // photo so we can grab its source.
            FBRequest *request2 = [FBRequest
                                   requestForGraphPath:@"{result=photopost:$.id}"];
            [connection addRequest:request2
                 completionHandler:
             ^(FBRequestConnection *connection, id result, NSError *error) {
                 if (!error &&
                     result) {
                     NSString *source = [result objectForKey:@"source"];
                     [self postOpenGraphActionWithPhotoURL:source
                                                  username:username];
                 }
             }
             ];
            
            [connection start];
        }
    }];
}

+ (void)postOpenGraphActionWithPhotoURL:(NSString*)photoURL
                               username:(NSString *)username
{
    // First create the Open Graph meal object for the meal we ate.
    id<OGPerson> person = [self userForUsername:username];
    
    // Now create an Open Graph eat action with the meal, our location,
    // and the people we were with.
    id<OGVoteAction> action =
    (id<OGVoteAction>)[FBGraphObject graphObject];
    action.person = person;
    
    if (photoURL) {
        NSMutableDictionary *image = [[NSMutableDictionary alloc] init];
        [image setObject:photoURL forKey:@"url"];
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        [images addObject:image];
        
        action.image = images;
    }
    
    // Create the request and post the action to the
    // "me/<YOUR_APP_NAMESPACE>:eat" path.
    [FBRequestConnection startForPostWithGraphPath:@"me/hotterapp:vote%20for"
                                       graphObject:action
                                 completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         NSString *alertText;
         if (!error) {
             alertText = @"Shared on Facebook!";
         } else {
             alertText = @"Failed to share on Facebook.";
         }
         [[[UIAlertView alloc] initWithTitle:@"Share Vote"
                                     message:alertText
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil]
          show];
     }
     ];
}

+ (void)postOpenGraphActionWithPhotoURL:(NSString*)photoURL
                               username:(NSString *)username
                               timeLeft:(NSInteger)timeLeft
{
    // First create the Open Graph meal object for the meal we ate.
    id<OGPerson> person = [self userForUsername:username];
    
    // Now create an Open Graph eat action with the meal, our location,
    // and the people we were with.
    id<OGCompeteAction> action = (id<OGCompeteAction>)[FBGraphObject graphObject];
    action.person = person;
    [action setObject:@(timeLeft).description forKey:@"expires_in"];
    
    if (photoURL) {
        NSMutableDictionary *image = [[NSMutableDictionary alloc] init];
        [image setObject:photoURL forKey:@"url"];
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        [images addObject:image];
        
        action.image = images;
    }
    
    // Create the request and post the action to the
    // "me/<YOUR_APP_NAMESPACE>:eat" path.
    [FBRequestConnection startForPostWithGraphPath:@"me/hotterapp:compete%20against"
                                       graphObject:action
                                 completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         NSString *alertText;
         if (!error) {
             alertText = @"Shared on Facebook!";
         } else {
             alertText = @"Failed to share on Facebook.";
         }
         [[[UIAlertView alloc] initWithTitle:@"Share Competition"
                                     message:alertText
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil]
          show];
     }
     ];
}

@end
