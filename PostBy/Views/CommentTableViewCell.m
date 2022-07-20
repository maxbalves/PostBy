//
//  CommentTableViewCell.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/20/22.
//

// View
#import "CommentTableViewCell.h"

// Frameworks
#import "UIImageView+AFNetworking.h"

@implementation CommentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void) setCommentVM:(CommentViewModel *)commentVM {
    _commentVM = commentVM;
    self.username.text = commentVM.username;
    self.commentText.text = commentVM.commentText;
    [self.profilePic setImageWithURL:commentVM.profilePicUrl];
    self.commentDate.text = commentVM.commentShortDate;
}

@end
