//
//  OpenGraphProtocols.h
//  WhosHotter
//
//  Created by Shuhan Bao on 12/10/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <UIKit/UIKit.h>

@protocol OGCompetition <FBGraphObject>

@end

@protocol OGPerson <FBGraphObject>

@property (nonatomic, readwrite) NSString *url;

@end

@protocol OGVoteAction <FBOpenGraphAction>

@property (nonatomic, readwrite) id<OGPerson>person;

@end
