//
//  Post.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// Frameworks
@import Parse;

// Model
#import "Post.h"

@implementation Post

@dynamic author;
@dynamic postText;
@dynamic commentCount;
@dynamic likeCount;
@dynamic dislikeCount;
@dynamic latitude;
@dynamic longitude;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void) postWithText:(NSString *)text withLat:(NSNumber *)latitude withLong:(NSNumber *)longitude withCompletion:(PFBooleanResultBlock)completion {
    Post *newPost = [Post new];
    newPost.author = [PFUser currentUser];
    newPost.postText = text;
    newPost.commentCount = @(0);
    newPost.likeCount = @(0);
    newPost.dislikeCount = @(0);
    
    newPost.latitude = latitude;
    newPost.longitude = longitude;
    
    [newPost saveInBackgroundWithBlock: completion];
}

@end
