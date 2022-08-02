//
//  PostViewModel.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/12/22.
//

// Global Variables
#import "GlobalVars.h"

// Frameworks
#import "DateTools.h"
@import Parse;

// Models
#import "Post.h"

// View Model
#import "CommentViewModel.h"
#import "PostViewModel.h"

@implementation PostViewModel

- (instancetype) initWithPost:(Post *)post {
    self = [super init];
    if (!self)
        return nil; // failure
    
    self.post = post;
    
    [self setPropertiesFromPost:post];
    
    // Likes - Default
    self.isLiked = NO;
    self.likeCountStr = [NSString stringWithFormat:@"%@", post.likeCount];
    self.likeButtonImg = [UIImage systemImageNamed:@"arrow.up.circle"];
    
    // Dislikes - Default
    self.isDisliked = NO;
    self.dislikeCountStr = [NSString stringWithFormat:@"%@", post.dislikeCount];
    self.dislikeButtonImg = [UIImage systemImageNamed:@"arrow.down.circle"];
    
    [self checkIfLiked];
    [self checkIfDisliked];
    
    return self;
}

- (void) setPropertiesFromPost:(Post *)post {
    if (post.hideProfilePic) {
        self.profilePicUrl = nil;
    } else {
        PFFileObject *profilePicObj = post.author[PROFILE_PIC_FIELD];
        self.profilePicUrl = [NSURL URLWithString:profilePicObj.url];
    }
    
    if (post.hideUsername) {
        self.username = ANON_USERNAME;
    } else {
        self.username = post.author.username;
    }
    
    self.postText = post.postText;
    
    // Format and set createdAtString
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    // Configure the input format to parse the date string
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    
    // Configure output format
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    self.postDate = [formatter stringFromDate:post.createdAt];
    
    // Create short date for time since post creation
    self.postShortDate = post.createdAt.shortTimeAgoSinceNow;
    
    // Latitude & Longitude
    self.latitude = post.location.latitude;
    self.longitude = post.location.longitude;
    
    // Edit / Remove / Location buttons
    self.isAuthor = [post.author.username isEqualToString:PFUser.currentUser.username];
    self.hideLocation = !post.location || post.hideLocation;
    self.hideUsername = post.hideUsername;
    self.hideProfilePic = post.hideProfilePic;
}

- (void) reloadLikeDislikeData {
    // Likes
    self.likeCountStr = [NSString stringWithFormat:@"%@", self.post.likeCount];
    if (self.isLiked) {
        self.likeButtonImg = [UIImage systemImageNamed:@"arrow.up.circle.fill"];
    } else {
        self.likeButtonImg = [UIImage systemImageNamed:@"arrow.up.circle"];
    }
    
    // Dislikes
    self.dislikeCountStr = [NSString stringWithFormat:@"%@", self.post.dislikeCount];
    if (self.isDisliked) {
        self.dislikeButtonImg = [UIImage systemImageNamed:@"arrow.down.circle.fill"];
    } else {
        self.dislikeButtonImg = [UIImage systemImageNamed:@"arrow.down.circle"];
    }
}

- (void) checkIfLiked {
    PFRelation *userLikes = [PFUser.currentUser relationForKey:LIKES_RELATION];
    PFQuery *checkIfLiked = [userLikes query];
    [checkIfLiked whereKey:@"objectId" equalTo:self.post.objectId];
    [checkIfLiked findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.isLiked = objects.count > 0;
        [self reloadLikeDislikeData];
        [self.delegate didLoadLikeDislikeData];
    }];
}

- (void) checkIfDisliked {
    PFRelation *userDislikes = [PFUser.currentUser relationForKey:DISLIKES_RELATION];
    PFQuery *checkIfDisliked = [userDislikes query];
    [checkIfDisliked whereKey:@"objectId" equalTo:self.post.objectId];
    [checkIfDisliked findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.isDisliked = objects.count > 0;
        [self reloadLikeDislikeData];
        [self.delegate didLoadLikeDislikeData];
    }];
}

- (void) likeButtonTap {
    [self interactWithPostBy:@"like"];
}

- (void) dislikeButtonTap {
    [self interactWithPostBy:@"dislike"];
}

- (void) interactWithPostBy:(NSString *)action {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:POST_CLASS];
    [query includeKey:AUTHOR_FIELD];
    [query whereKey:@"objectId" equalTo:self.post.objectId];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            if (posts.count > 0) {
                // Update queried post to reflect local post
                Post *queriedPost = posts[0];
                
                // Update our post to be the queried post without the like/dislike as DB
                self.post = queriedPost;
                [self resetParsePostToLocalPost];
                
                [PFUser.currentUser save];
                [self.post save];
                
                // Perform action based on local post
                if ([action isEqualToString:@"like"]) {
                    [self likeAction];
                } else if ([action isEqualToString:@"dislike"]) {
                    [self dislikeAction];
                }
                [self saveAndRefresh];
            } else {
                // Invalid / Deleted Post
                [self.delegate postNotFound:self];
            }
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void) likeAction {
    if (self.isLiked) {
        [self unlikePost];
    } else {
        [self likePost];
        if (self.isDisliked) {
            [self undislikePost];
        }
    }
}

- (void) dislikeAction {
    if (self.isDisliked) {
        [self undislikePost];
    } else {
        [self dislikePost];
        if (self.isLiked) {
            [self unlikePost];
        }
    }
}

- (void) resetParsePostToLocalPost {
    [PFUser.currentUser fetch];
    
    PFRelation *queriedPostLikesRelation = [self.post relationForKey:LIKES_RELATION];
    PFQuery *checkIfLikedQuery = [queriedPostLikesRelation query];
    [checkIfLikedQuery whereKey:@"objectId" equalTo:PFUser.currentUser.objectId];
    NSArray *likedResult = [checkIfLikedQuery findObjects];
    
    PFRelation *queriedPostDislikesRelation = [self.post relationForKey:DISLIKES_RELATION];
    PFQuery *checkIfDislikedQuery = [queriedPostDislikesRelation query];
    [checkIfDislikedQuery whereKey:@"objectId" equalTo:PFUser.currentUser.objectId];
    NSArray *dislikedResult = [checkIfDislikedQuery findObjects];
    
    // Check if not liked
    if (self.isLiked && likedResult.count == 0) {
        [self likePost];
    }
    
    // Check if not disliked
    if (self.isDisliked && dislikedResult.count == 0) {
        [self dislikePost];
    }
    
    // Check if not unliked
    if (!self.isLiked && likedResult.count > 0) {
        [self unlikePost];
    }
    
    // Check if not undisliked
    if (!self.isDisliked && dislikedResult.count > 0) {
        [self undislikePost];
    }
}

- (void) likePost {
    self.isLiked = YES;
    self.post.likeCount = @(self.post.likeCount.intValue + 1);
    [[self.post relationForKey:LIKES_RELATION] addObject:PFUser.currentUser];
    [[PFUser.currentUser relationForKey:LIKES_RELATION] addObject:self.post];
}

- (void) unlikePost {
    self.isLiked = NO;
    self.post.likeCount = @(self.post.likeCount.intValue - 1);
    [[self.post relationForKey:LIKES_RELATION] removeObject:PFUser.currentUser];
    [[PFUser.currentUser relationForKey:LIKES_RELATION] removeObject:self.post];
}

- (void) dislikePost {
    self.isDisliked = YES;
    self.post.dislikeCount = @(self.post.dislikeCount.intValue + 1);
    [[self.post relationForKey:DISLIKES_RELATION] addObject:PFUser.currentUser];
    [[PFUser.currentUser relationForKey:DISLIKES_RELATION] addObject:self.post];
}

- (void) undislikePost {
    self.isDisliked = NO;
    self.post.dislikeCount = @(self.post.dislikeCount.intValue - 1);
    [[self.post relationForKey:DISLIKES_RELATION] removeObject:PFUser.currentUser];
    [[PFUser.currentUser relationForKey:DISLIKES_RELATION] removeObject:self.post];
}

- (void) saveAndRefresh {
    [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [PFUser.currentUser saveInBackground];
    }];
    [self reloadLikeDislikeData];
    [self.delegate didLoadLikeDislikeData];
}

- (void) deletePost {
    NSDictionary *params = @{
        CLOUD_POSTID_FIELD : self.post.objectId,
        CLOUD_LIKES_RELATION : LIKES_RELATION,
        CLOUD_DISLIKES_RELATION : DISLIKES_RELATION,
        CLOUD_COMMENT_CLASS : COMMENT_CLASS,
        CLOUD_COMMENTS_RELATION : COMMENTS_RELATION,
        CLOUD_POST_CLASS : POST_CLASS,
        CLOUD_POSTS_RELATION : POSTS_RELATION,
        CLOUD_POST_FIELD : POST_FIELD,
        CLOUD_AUTHOR_FIELD : AUTHOR_FIELD,
        @"useMasterKey" : @true
    };

    [PFCloud callFunctionInBackground:CLOUD_DELETE_POST_FUNC withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void) updateWithText:(NSString *)newPostText hideLocation:(BOOL)hideLocation hideUsername:(BOOL)hideUsername hideProfilePic:(BOOL)hideProfilePic {
    NSString *oldPostText = self.post.postText;
    BOOL oldHideLocation = self.post.hideLocation;
    BOOL oldHideUsername = self.post.hideUsername;
    BOOL oldHideProfilePic = self.post.hideProfilePic;
    
    self.post.postText = newPostText;
    self.post.hideLocation = hideLocation;
    self.post.hideUsername = hideUsername;
    self.post.hideProfilePic = hideProfilePic;
    
    NSError *__autoreleasing  _Nullable * _Nullable error = nil;
    [self.post save:error];
    
    if (error) {
        // If error, fall back to previous data
        self.post.postText = oldPostText;
        self.post.hideLocation = oldHideLocation;
        self.post.hideUsername = oldHideUsername;
        self.post.hideProfilePic = oldHideProfilePic;
    } else {
        [self setPropertiesFromPost:self.post];
        [self reloadLikeDislikeData];
    }
}

+ (NSMutableArray *)postVMsWithArray:(NSArray *)posts {
    NSMutableArray *postVMsArray = [NSMutableArray new];
    for (Post *post in posts) {
        PostViewModel *postVM = [[PostViewModel alloc] initWithPost:post];
        [postVMsArray addObject:postVM];
    }
    return postVMsArray;
}

@end
