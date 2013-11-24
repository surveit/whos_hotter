//
//  Comment.h
//  WhosHotter
//
//  Created by Shuhan Bao on 11/17/13.
//  Copyright (c) 2013 Awesome Apps. All rights reserved.
//

#import "PersistedObject.h"

@interface Comment : PersistedObject

+ (Comment *)postCommentWithCompetitionId:(NSString *)identifier
                                     text:(NSString *)text;

+ (NSArray *)commentsFromArrayOfCommentModels:(NSArray *)models;

+ (NSString *)isValidCommentText:(NSString *)text;

@end