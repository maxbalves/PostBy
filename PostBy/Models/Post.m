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
@dynamic hideLocation;
@dynamic latitude;
@dynamic longitude;
@dynamic likeCount;
@dynamic dislikeCount;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void) postWithText:(NSString *)text withLat:(NSNumber *)latitude withLong:(NSNumber *)longitude withCompletion:(PFBooleanResultBlock)completion {
    Post *newPost = [Post new];
    newPost.author = [PFUser currentUser];
    newPost.postText = text;
    newPost.likeCount = @(0);
    newPost.dislikeCount = @(0);
    
    newPost.latitude = latitude;
    newPost.longitude = longitude;
    
    // TODO: Implement option to hide or show location
    newPost.hideLocation = NO;
    
    [newPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        PFRelation *userPosts = [PFUser.currentUser relationForKey:@"posts"];
        
        [userPosts addObject:newPost];
        
        [PFUser.currentUser saveInBackgroundWithBlock:completion];
    }];
}

@end
