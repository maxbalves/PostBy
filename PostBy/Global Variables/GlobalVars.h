//
//  GlobalVars.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/18/22.
//

// Frameworks
#import <Foundation/Foundation.h>

// Definitions
#define DARK_THEME_COLOR [UIColor colorWithRed:(64.0/255.0) green:(63.0/255.0) blue:(76.0/255.0) alpha:1]

extern NSString *const MAIN_STORYBOARD;

extern NSString *const DEFAULT_PROFILE_PIC;

extern NSInteger const CELL_BORDER_WIDTH;
extern NSInteger const CORNER_RADIUS_DIV_CONST;
extern NSInteger const PIN_IMG_WIDTH;
extern NSInteger const PIN_IMG_HEIGHT;

// Parse Related Variables
extern NSString *const POST_CLASS;
extern NSString *const COMMENT_CLASS;

extern NSString *const ANON_USERNAME;

extern NSString *const AUTHOR_FIELD;
extern NSString *const LOCATION_FIELD;
extern NSString *const POST_FIELD;
extern NSString *const PROFILE_PIC_FIELD;

extern NSString *const POSTS_RELATION;
extern NSString *const COMMENTS_RELATION;
extern NSString *const LIKES_RELATION;
extern NSString *const DISLIKES_RELATION;

// Cloud Code Related Functions
extern NSString *const CLOUD_DELETE_ACCOUNT_FUNC;
extern NSString *const CLOUD_DELETE_COMMENT_FUNC;
extern NSString *const CLOUD_DELETE_COMMENTS_FUNC;
extern NSString *const CLOUD_DELETE_DISLIKES_FUNC;
extern NSString *const CLOUD_DELETE_LIKES_FUNC;
extern NSString *const CLOUD_DELETE_POST_FUNC;
extern NSString *const CLOUD_DELETE_POSTS_FUNC;

extern NSString *const CLOUD_AUTHOR_FIELD;
extern NSString *const CLOUD_COMMENT_CLASS;
extern NSString *const CLOUD_COMMENTID_FIELD;
extern NSString *const CLOUD_COMMENTS_RELATION;
extern NSString *const CLOUD_DISLIKES_RELATION;
extern NSString *const CLOUD_LIKES_RELATION;
extern NSString *const CLOUD_POST_CLASS;
extern NSString *const CLOUD_POST_FIELD;
extern NSString *const CLOUD_POSTID_FIELD;
extern NSString *const CLOUD_POSTS_RELATION;
