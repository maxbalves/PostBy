//
//  PostTableViewCell.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/6/22.
//

// Models
#import "Post.h"

// Frameworks
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PostTableViewCell : UITableViewCell

@property (strong, nonatomic) Post *post;

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *postTextLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;

@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;

@end

NS_ASSUME_NONNULL_END
