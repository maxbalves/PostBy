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

NSString *const DEFAULT_PROFILE_PIC = @"profile_tab.png";

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
