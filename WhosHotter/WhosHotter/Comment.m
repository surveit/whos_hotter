//
//  Comment.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "Comment.h"
#import "Config.h"
#import "User.h"

#import <Parse/Parse.h>

@implementation Comment

+ (Comment *)postCommentWithCompetitionId:(NSString *)identifier
                                     text:(NSString *)text {
    Comment *comment = [self newObject];
    
    [comment setValue:text forKey:@"text"];
    [comment setValue:identifier forKey:@"competitionIdentifier"];
    [comment setValue:[User identifier] forKey:@"userIdentifier"];
    [comment setValue:[User username] forKey:@"username"];
    [comment saveInBackgroundWithCompletionHandler:nil];
    
    return comment;
}

+ (NSString *)isValidCommentText:(NSString *)text {
    if (text.length >= [Config maxCommentLength]) {
        return [NSString stringWithFormat:@"Comments must be fewer than %ld characeters!",[Config maxCommentLength]];
    }
    return nil;
}

+ (NSArray *)commentsFromArrayOfCommentModels:(NSArray *)models {
    NSMutableArray *comments = [NSMutableArray array];
    for (PFObject *model in models) {
        Comment *comment = [Comment objectWithModel:model];
        [comments addObject:comment];
    }
    return comments;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@",[self valueForKey:@"username"],[self valueForKey:@"text"]];
}

- (NSString *)username {
    return [self valueForKey:@"username"];
}

- (NSString *)text {
    return [self valueForKey:@"text"];
}

@end
