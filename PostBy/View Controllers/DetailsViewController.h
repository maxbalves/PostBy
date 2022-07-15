//
//  DetailsViewController.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// View Models
#import "PostViewModel.h"

// Frameworks
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController <PostViewModelDelegate>

@property (strong, nonatomic) PostViewModel *postVM;

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *postTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *postDateLabel;

@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *dislikeButton;

@property (strong, nonatomic) IBOutlet UIButton *pinLocationButton;
@property (strong, nonatomic) IBOutlet UIButton *editButton;
@property (strong, nonatomic) IBOutlet UIButton *deleteButton;

@end

NS_ASSUME_NONNULL_END
