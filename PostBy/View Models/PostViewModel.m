//
//  PostViewModel.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/12/22.
//

// Frameworks
#import "DateTools.h"
@import Parse;

// Models
#import "Post.h"

// View Model
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
        PFFileObject *profilePicObj = post.author[@"profilePicture"];
        self.profilePicUrl = [NSURL URLWithString:profilePicObj.url];
    }
    
    if (post.hideUsername) {
        self.username = @" ";
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
    PFRelation *userLikes = [PFUser.currentUser relationForKey:@"likes"];
    PFQuery *checkIfLiked = [userLikes query];
    [checkIfLiked whereKey:@"objectId" equalTo:self.post.objectId];
    [checkIfLiked findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.isLiked = objects.count > 0;
        [self reloadLikeDislikeData];
        [self.delegate didLoadLikeDislikeData];
    }];
}

- (void) checkIfDisliked {
    PFRelation *userDislikes = [PFUser.currentUser relationForKey:@"dislikes"];
    PFQuery *checkIfDisliked = [userDislikes query];
    [checkIfDisliked whereKey:@"objectId" equalTo:self.post.objectId];
    [checkIfDisliked findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.isDisliked = objects.count > 0;
        [self reloadLikeDislikeData];
        [self.delegate didLoadLikeDislikeData];
    }];
}

- (void) likeButtonTap {
    if (self.isLiked) {
        [self unlikePost];
    } else {
        [self likePost];
        if (self.isDisliked) {
            [self undislikePost];
        }
    }
    
    [self saveAndRefresh];
}

- (void) dislikeButtonTap {
    if (self.isDisliked) {
        [self undislikePost];
    } else {
        [self dislikePost];
        if (self.isLiked) {
            [self unlikePost];
        }
    }
    
    [self saveAndRefresh];
}

- (void) likePost {
    self.isLiked = YES;
    self.post.likeCount = @(self.post.likeCount.intValue + 1);
    [[self.post relationForKey:@"likes"] addObject:PFUser.currentUser];
    [[PFUser.currentUser relationForKey:@"likes"] addObject:self.post];
}

- (void) unlikePost {
    self.isLiked = NO;
    self.post.likeCount = @(self.post.likeCount.intValue - 1);
    [[self.post relationForKey:@"likes"] removeObject:PFUser.currentUser];
    [[PFUser.currentUser relationForKey:@"likes"] removeObject:self.post];
}

- (void) dislikePost {
    self.isDisliked = YES;
    self.post.dislikeCount = @(self.post.dislikeCount.intValue + 1);
    [[self.post relationForKey:@"dislikes"] addObject:PFUser.currentUser];
    [[PFUser.currentUser relationForKey:@"dislikes"] addObject:self.post];
}

- (void) undislikePost {
    self.isDisliked = NO;
    self.post.dislikeCount = @(self.post.dislikeCount.intValue - 1);
    [[self.post relationForKey:@"dislikes"] removeObject:PFUser.currentUser];
    [[PFUser.currentUser relationForKey:@"dislikes"] removeObject:self.post];
}

- (void) saveAndRefresh {
    [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [PFUser.currentUser saveInBackground];
    }];
    [self reloadLikeDislikeData];
}

- (void) deletePost {
    // Delete comments
    PFRelation *commentsRelation = [self.post relationForKey:@"comments"];
    NSArray *comments = [[commentsRelation query] findObjects];
    for (PFObject *comment in comments) {
        [comment delete];
    }
    
    [self.post delete];
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
        self.post.postText = oldPostText;
        self.post.hideLocation = oldHideLocation;
        self.post.hideUsername = oldHideUsername;
        self.post.hideProfilePic = oldHideProfilePic;
    } else {
        [self setPropertiesFromPost:self.post];
        [self reloadLikeDislikeData];
    }
}

+ (NSArray *)postVMsWithArray:(NSArray *)posts {
    NSMutableArray *postVMsArray = [NSMutableArray new];
    for (Post *post in posts) {
        PostViewModel *postVM = [[PostViewModel alloc] initWithPost:post];
        [postVMsArray addObject:postVM];
    }
    return postVMsArray;
}

@end
