//
//  PostTableViewCell.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/6/22.
//

// Views
#import "PostTableViewCell.h"

// Frameworks
#import "UIImageView+AFNetworking.h"

@implementation PostTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setPost:(Post *)post {
    _post = post;
    
    self.usernameLabel.text = post.author.username;
    self.postTextLabel.text = post.postText;
    
    PFFileObject *profilePicObj = [post.author valueForKey:@"profilePicture"];;
    NSURL *url = [NSURL URLWithString:profilePicObj.url];
    [self.profilePicture setImageWithURL:url];
    
    NSString *likeCount = [NSString stringWithFormat:@"%@", post.likeCount];
    [self.likeButton setTitle:likeCount forState:UIControlStateNormal];
    [self.likeButton setTitle:likeCount forState:UIControlStateHighlighted];
    [self.likeButton setTitle:likeCount forState:UIControlStateSelected];
    
    NSString *dislikeCount = [NSString stringWithFormat:@"%@", post.dislikeCount];
    [self.dislikeButton setTitle:dislikeCount forState:UIControlStateNormal];
    [self.dislikeButton setTitle:dislikeCount forState:UIControlStateHighlighted];
    [self.dislikeButton setTitle:dislikeCount forState:UIControlStateSelected];
}

@end
