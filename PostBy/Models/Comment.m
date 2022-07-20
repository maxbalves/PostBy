//
//  Comment.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/20/22.
//

// Model
#import "Comment.h"

// Frameworks
@import Parse;

@implementation Comment

@dynamic post;
@dynamic author;
@dynamic commentText;
@dynamic hideUsername;
@dynamic hideProfilePic;

+ (nonnull NSString *)parseClassName {
    return @"Comment";
}

+ (void)commentWithText:(NSString *)text onPost:(Post *)post hideUsername:(BOOL)hideUsername hideProfilePic:(BOOL)hideProfilePic withCompletion:(PFBooleanResultBlock)completion {
    Comment *newComment = [Comment new];
    newComment.post = post;
    newComment.author = [PFUser currentUser];
    newComment.commentText = text;
    newComment.hideUsername = hideUsername;
    newComment.hideProfilePic = hideProfilePic;
    
    [newComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        // Add comment to its post's "comments" relation
        PFRelation *postCommentsRelation = [post relationForKey:@"comments"];
        [postCommentsRelation addObject:newComment];
        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            // Add comment to user's "comments" relation
            PFRelation *userComments = [PFUser.currentUser relationForKey:@"comments"];
            [userComments addObject:newComment];
            [PFUser.currentUser saveInBackgroundWithBlock:completion];
        }];
    }];
}

@end
