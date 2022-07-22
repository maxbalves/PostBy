//
//  Post.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// Global Variables
#import "GlobalVars.h"

// Frameworks
@import Parse;

// Model
#import "Post.h"

@implementation Post

@dynamic author;
@dynamic postText;
@dynamic location;
@dynamic hideLocation;
@dynamic hideUsername;
@dynamic hideProfilePic;
@dynamic likeCount;
@dynamic dislikeCount;

+ (nonnull NSString *)parseClassName {
    return POST_CLASS;
}

+ (void) postWithText:(NSString *)text withLocation:(PFGeoPoint *)location hideLocation:(BOOL)hideLocation hideUsername:(BOOL)hideUsername hideProfilePic:(BOOL)hideProfilePic  withCompletion:(PFBooleanResultBlock)completion {
    Post *newPost = [Post new];
    newPost.author = [PFUser currentUser];
    newPost.postText = text;
    newPost.likeCount = @(0);
    newPost.dislikeCount = @(0);
    
    newPost.location = location;
    
    // Privacy Options
    newPost.hideLocation = hideLocation;
    newPost.hideUsername = hideUsername;
    newPost.hideProfilePic = hideProfilePic;
    
    [newPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        PFRelation *userPosts = [PFUser.currentUser relationForKey:POSTS_RELATION];
        
        [userPosts addObject:newPost];
        
        [PFUser.currentUser saveInBackgroundWithBlock:completion];
    }];
}

@end
