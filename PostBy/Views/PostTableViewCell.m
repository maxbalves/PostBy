//
//  PostTableViewCell.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/6/22.
//

// Global Variables
#import "GlobalVars.h"

// Views
#import "PostTableViewCell.h"

// View Models
#import "PostViewModel.h"

// Frameworks
#import "UIImageView+AFNetworking.h"

@implementation PostTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void) setPostVM:(PostViewModel *)postVM {
    postVM.delegate = self;
    
    _postVM = postVM;
    
    [self refreshCell];
}

- (void) didLoadLikeDislikeData {
    [self refreshCell];
}

- (void) refreshCell {
    self.usernameLabel.text = self.postVM.username;
    self.postTextLabel.text = self.postVM.postText;
    self.shortDate.text = self.postVM.postShortDate;
    
    if (self.postVM.profilePicUrl != nil) {
        [self.profilePicture setImageWithURL:self.postVM.profilePicUrl];
    } else {
        [self.profilePicture setImage:[UIImage imageNamed:DEFAULT_PROFILE_PIC]];
    }
    
    [self refreshLikeDislikeUI];
}

- (void) refreshLikeDislikeUI {
    // Like
    [self.likeButton setTitle:self.postVM.likeCountStr forState:UIControlStateNormal];
    [self.likeButton setTitle:self.postVM.likeCountStr forState:UIControlStateHighlighted];
    [self.likeButton setTitle:self.postVM.likeCountStr forState:UIControlStateSelected];
    
    [self.likeButton setImage:self.postVM.likeButtonImg forState:UIControlStateNormal];
    [self.likeButton setImage:self.postVM.likeButtonImg forState:UIControlStateSelected];
    [self.likeButton setImage:self.postVM.likeButtonImg forState:UIControlStateHighlighted];
    
    // Dislike
    [self.dislikeButton setTitle:self.postVM.dislikeCountStr forState:UIControlStateNormal];
    [self.dislikeButton setTitle:self.postVM.dislikeCountStr forState:UIControlStateHighlighted];
    [self.dislikeButton setTitle:self.postVM.dislikeCountStr forState:UIControlStateSelected];
    
    [self.dislikeButton setImage:self.postVM.dislikeButtonImg forState:UIControlStateNormal];
    [self.dislikeButton setImage:self.postVM.dislikeButtonImg forState:UIControlStateSelected];
    [self.dislikeButton setImage:self.postVM.dislikeButtonImg forState:UIControlStateHighlighted];
}

- (IBAction)likeButtonTap:(id)sender {
    self.likeButton.userInteractionEnabled = NO;
    self.dislikeButton.userInteractionEnabled = NO;
    
    [self.postVM likeButtonTap];
    [self refreshLikeDislikeUI];
    
    self.likeButton.userInteractionEnabled = YES;
    self.dislikeButton.userInteractionEnabled = YES;
}

- (IBAction)dislikeButtonTap:(id)sender {
    self.likeButton.userInteractionEnabled = NO;
    self.dislikeButton.userInteractionEnabled = NO;
    
    [self.postVM dislikeButtonTap];
    [self refreshLikeDislikeUI];
    
    self.likeButton.userInteractionEnabled = YES;
    self.dislikeButton.userInteractionEnabled = YES;
}

@end
