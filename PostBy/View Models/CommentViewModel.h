//
//  CommentViewModel.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/20/22.
//

// Models
#import "Comment.h"

// Frameworks
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommentViewModel : NSObject

@property (strong, nonatomic) Comment *comment;
@property (strong, nonatomic, nullable) NSURL *profilePicUrl;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *commentText;
@property (strong, nonatomic) NSString *commentShortDate;

@property (nonatomic) BOOL hideUsername;
@property (nonatomic) BOOL hideProfilePic;

- (void) deleteComment;

+ (NSMutableArray *)commentVMsWithArray:(NSArray *)comments;

@end

NS_ASSUME_NONNULL_END
