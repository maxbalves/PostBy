//
//  PostViewModel.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/12/22.
//

// Frameworks
#import <Foundation/Foundation.h>

// Models
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PostViewModelDelegate <NSObject>

- (void) didLoadLikeDislikeData;

- (void) didUpdatePost;

@end

@interface PostViewModel : NSObject

@property (nonatomic, weak) id<PostViewModelDelegate> delegate;

@property (strong, nonatomic) Post *post;
@property (strong, nonatomic, nullable) NSURL *profilePicUrl;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *postText;
@property (strong, nonatomic) NSString *postDate;
@property (strong, nonatomic) NSString *postShortDate;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@property (strong, nonatomic) NSString *likeCountStr;
@property (strong, nonatomic) NSString *dislikeCountStr;

@property (strong, nonatomic) UIImage *likeButtonImg;
@property (strong, nonatomic) UIImage *dislikeButtonImg;

@property (nonatomic) BOOL isAuthor;
@property (nonatomic) BOOL hideLocation;
@property (nonatomic) BOOL hideUsername;
@property (nonatomic) BOOL hideProfilePic;

@property (nonatomic) BOOL isLiked;
@property (nonatomic) BOOL isDisliked;

- (void) likeButtonTap;

- (void) dislikeButtonTap;

- (void) deletePost;

- (void) updateWithText:(NSString *)newPostText hideLocation:(BOOL)hideLocation hideUsername:(BOOL)hideUsername hideProfilePic:(BOOL)hideProfilePic;

+ (NSArray *)postVMsWithArray:(NSArray *)posts;

@end

NS_ASSUME_NONNULL_END
