//
//  GlobalVars.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/18/22.
//

// Header
#import "GlobalVars.h"

// Frameworks
#import <Foundation/Foundation.h>

// !IMPORTANT: Any changes made to fields below will need to be manually done in Parse Server's Background Jobs
// For example, in removeOldPosts job, we will need to manually update the COMMENTS_RELATION if there are any changes

NSString *const MAIN_STORYBOARD = @"Main";

NSString *const DEFAULT_PROFILE_PIC = @"profile_tab.png";

NSInteger const CELL_BORDER_WIDTH = 5;
NSInteger const CORNER_RADIUS_DIV_CONST = 8;
NSInteger const PIN_IMG_WIDTH = 50;
NSInteger const PIN_IMG_HEIGHT = 50;

// Parse Related Variables
NSString *const POST_CLASS = @"Post";
NSString *const COMMENT_CLASS = @"Comment";

NSString *const ANON_USERNAME = @" ";

NSString *const AUTHOR_FIELD = @"author";
NSString *const LOCATION_FIELD = @"location";
NSString *const POST_FIELD = @"post";
NSString *const PROFILE_PIC_FIELD = @"profilePicture";

NSString *const POSTS_RELATION = @"posts";
NSString *const COMMENTS_RELATION = @"comments";
NSString *const LIKES_RELATION = @"likes";
NSString *const DISLIKES_RELATION = @"dislikes";

// Cloud Code Related Variables
NSString *const CLOUD_DELETE_ACCOUNT_FUNC = @"deleteAccount";
NSString *const CLOUD_DELETE_COMMENT_FUNC = @"deleteComment";
NSString *const CLOUD_DELETE_COMMENTS_FUNC = @"deleteComments";
NSString *const CLOUD_DELETE_DISLIKES_FUNC = @"deleteDislikes";
NSString *const CLOUD_DELETE_LIKES_FUNC = @"deleteLikes";
NSString *const CLOUD_DELETE_POST_FUNC = @"deletePost";
NSString *const CLOUD_DELETE_POSTS_FUNC = @"deletePosts";

NSString *const CLOUD_AUTHOR_FIELD = @"authorField";
NSString *const CLOUD_COMMENT_CLASS = @"commentClassName";
NSString *const CLOUD_COMMENTID_FIELD = @"commentId";
NSString *const CLOUD_COMMENTS_RELATION = @"commentsRelationName";
NSString *const CLOUD_DISLIKES_RELATION = @"dislikesRelationName";
NSString *const CLOUD_LIKES_RELATION = @"likesRelationName";
NSString *const CLOUD_POST_CLASS = @"postClassName";
NSString *const CLOUD_POST_FIELD = @"postField";
NSString *const CLOUD_POSTID_FIELD = @"postId";
NSString *const CLOUD_POSTS_RELATION = @"postsRelationName";
