//
//  Comment.m
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "Comment.h"

@implementation Comment

+ (Comment *)postCommentWithCompetitionId:(NSString *)identifier
                                     text:(NSString *)text {
    Comment *comment = [self newObject];
    comment.model[@"text"] = text;
    comment.model[@"competitionIdentifier"] = identifier;
    comment.model[@"userIdentifier"] = [[PFUser currentUser] objectId];
    comment.model[@"username"] = [[PFUser currentUser] username];
    [comment.model saveInBackground];
    return comment;
}

@end
