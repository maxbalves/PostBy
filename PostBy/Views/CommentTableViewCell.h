//
//  CommentTableViewCell.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/20/22.
//

// View Models
#import "CommentViewModel.h"

// Frameworks
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommentTableViewCell : UITableViewCell

@property (strong, nonatomic) CommentViewModel *commentVM;

@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UIImageView *profilePic;
@property (strong, nonatomic) IBOutlet UILabel *commentText;
@property (strong, nonatomic) IBOutlet UILabel *commentDate;

@end

NS_ASSUME_NONNULL_END
