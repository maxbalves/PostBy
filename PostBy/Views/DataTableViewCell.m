//
//  DataTableViewCell.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/27/22.
//

// Views
#import "DataTableViewCell.h"

// Global Variables
#import "GlobalVars.h"

// Frameworks
#import "UIImageView+AFNetworking.h"

@implementation DataTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.borderWidth = CELL_BORDER_WIDTH;
    self.layer.borderColor = [[UIColor systemGray6Color] CGColor];
    self.layer.cornerRadius = self.frame.size.height / CORNER_RADIUS_DIV_CONST;
    
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.height / CORNER_RADIUS_DIV_CONST;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setCommentVM:(CommentViewModel *)commentVM {
    _commentVM = commentVM;
    
    // Set up UI based on commentVM
    self.usernameLabel.text = commentVM.username;
    self.dateLabel.text = commentVM.commentShortDate;
    self.dataTextLabel.text = commentVM.commentText;
    
    if (commentVM.profilePicUrl == nil) {
        [self.profilePicture setImage:[UIImage imageNamed:DEFAULT_PROFILE_PIC]];
    } else {
        [self.profilePicture setImageWithURL:commentVM.profilePicUrl];
    }
}

- (void) setPostVM:(PostViewModel *)postVM {
    _postVM = postVM;
    
    // Set up UI based on postVM
    self.usernameLabel.text = postVM.username;
    self.dateLabel.text = postVM.postShortDate;
    self.dataTextLabel.text = postVM.postText;
    
    if (postVM.profilePicUrl == nil) {
        [self.profilePicture setImage:[UIImage imageNamed:DEFAULT_PROFILE_PIC]];
    } else {
        [self.profilePicture setImageWithURL:postVM.profilePicUrl];
    }
}


@end
