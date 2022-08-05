//
//  CommentTableViewCell.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/20/22.
//

// View
#import "CommentTableViewCell.h"

// Global Variables
#import "GlobalVars.h"

// Frameworks
#import "UIImageView+AFNetworking.h"

@implementation CommentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.borderWidth = CELL_BORDER_WIDTH;
    self.layer.borderColor = [[UIColor systemGray6Color] CGColor];
    self.layer.cornerRadius = self.frame.size.height / CORNER_RADIUS_DIV_CONST;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setCommentVM:(CommentViewModel *)commentVM {
    _commentVM = commentVM;
    
    // Set up UI
    self.username.text = commentVM.username;
    self.commentText.text = commentVM.commentText;
    self.commentDate.text = commentVM.commentShortDate;
    
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / CORNER_RADIUS_DIV_CONST;
    if (commentVM.profilePicUrl == nil) {
        [self.profilePic setImage:[UIImage imageNamed:DEFAULT_PROFILE_PIC]];
    } else {
        [self.profilePic setImageWithURL:commentVM.profilePicUrl];
    }
}

@end
