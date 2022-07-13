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
    
    _post = post;
    
    if (post.hideProfilePic) {
        _profilePicUrl = nil;
    } else {
        PFFileObject *profilePicObj = post.author[@"profilePicture"];
        _profilePicUrl = [NSURL URLWithString:profilePicObj.url];
    }
    
    if (post.hideUsername) {
        _username = @" ";
    } else {
        _username = post.author.username;
    }
    
    _postText = post.postText;
    
    // Format and set createdAtString
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    // Configure the input format to parse the date string
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    
    // Configure output format
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    
    _postDate = [formatter stringFromDate:post.createdAt];
    
    // Create short date for time since post creation
    _postShortDate = post.createdAt.shortTimeAgoSinceNow;
    
    // Latitude & Longitude
    _latitude = post.location.latitude;
    _longitude = post.location.longitude;
    
    // Edit / Remove / Location buttons
    _isAuthor = [post.author.username isEqualToString:PFUser.currentUser.username];
    _hideLocation = !post.location || post.hideLocation;
    
    // Likes
    _likeCountStr = [NSString stringWithFormat:@"%@", post.likeCount];
    _isLiked = [self checkIfLiked];
    if (_isLiked) {
        _likeButtonImg = [UIImage systemImageNamed:@"arrow.up.circle.fill"];
    } else {
        _likeButtonImg = [UIImage systemImageNamed:@"arrow.up.circle"];
    }
    
    // Dislikes
    _dislikeCountStr = [NSString stringWithFormat:@"%@", post.dislikeCount];
    _isDisliked = [self checkIfDisliked];
    if (_isDisliked) {
        _dislikeButtonImg = [UIImage systemImageNamed:@"arrow.down.circle.fill"];
    } else {
        _dislikeButtonImg = [UIImage systemImageNamed:@"arrow.down.circle"];
    }
    
    return self;
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

- (BOOL) checkIfLiked {
    PFRelation *userLikes = [PFUser.currentUser relationForKey:@"likes"];
    PFQuery *checkIfLiked = [userLikes query];
    [checkIfLiked whereKey:@"objectId" equalTo:self.post.objectId];
    NSArray *liked = [checkIfLiked findObjects];
    
    return liked.count > 0;
}

- (BOOL) checkIfDisliked {
    PFRelation *userDislikes = [PFUser.currentUser relationForKey:@"dislikes"];
    PFQuery *checkIfDisliked = [userDislikes query];
    [checkIfDisliked whereKey:@"objectId" equalTo:self.post.objectId];
    NSArray *disliked = [checkIfDisliked findObjects];
    
    return disliked.count > 0;
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

+ (NSArray *)postVMsWithArray:(NSArray *)posts {
    NSMutableArray *postVMsArray = [NSMutableArray new];
    for (Post *post in posts) {
        PostViewModel *postVM = [[PostViewModel alloc] initWithPost:post];
        [postVMsArray addObject:postVM];
    }
    return postVMsArray;
}

@end
