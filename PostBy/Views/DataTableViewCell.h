//
//  DataTableViewCell.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/27/22.
//

// View Models
#import "CommentViewModel.h"
#import "PostViewModel.h"

// Frameworks
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataTableViewCell : UITableViewCell

@property (strong, nonatomic) CommentViewModel *commentVM;
@property (strong, nonatomic) PostViewModel *postVM;

@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UILabel *dataTextLabel;

@end

NS_ASSUME_NONNULL_END
