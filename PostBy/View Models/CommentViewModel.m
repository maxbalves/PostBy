//
//  CommentViewModel.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/20/22.
//

// Global Variables
#import "GlobalVars.h"

// Models
#import "Comment.h"

// View Models
#import "CommentViewModel.h"

// Frameworks
#import "DateTools.h"
@import Parse;

@implementation CommentViewModel

- (instancetype) initWithComment:(Comment *)comment {
    self = [super init];
    if (!self)
        return nil;
    
    self.comment = comment;
    self.commentText = comment.commentText;
    
    if (comment.hideUsername) {
        self.username = ANON_USERNAME;
    } else {
        self.username = comment.author.username;
    }
    
    if (comment.hideProfilePic) {
        self.profilePicUrl = nil;
    } else {
        PFFileObject *profilePicObj = comment.author[PROFILE_PIC_FIELD];
        self.profilePicUrl = [NSURL URLWithString:profilePicObj.url];
    }
    
    self.hideUsername = comment.hideUsername;
    self.hideProfilePic = comment.hideProfilePic;
    
    self.commentShortDate = comment.createdAt.shortTimeAgoSinceNow;
    
    return self;
}

- (void) deleteComment {
    NSDictionary *params = @{
        @"commentId" : self.comment.objectId,
        @"commentClassName" : COMMENT_CLASS,
        @"commentsRelationName" : COMMENTS_RELATION,
        @"postField" : POST_FIELD,
        @"useMasterKey" : @true
    };
    
    [PFCloud callFunctionInBackground:@"deleteComment" withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

+ (NSMutableArray *) commentVMsWithArray:(NSArray *)comments {
    NSMutableArray *commentVMsArray = [NSMutableArray new];
    for (Comment *comment in comments) {
        CommentViewModel *commentVM = [[CommentViewModel alloc] initWithComment:comment];
        [commentVMsArray addObject:commentVM];
    }
    return commentVMsArray;
}

@end
