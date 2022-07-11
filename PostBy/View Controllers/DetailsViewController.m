//
//  DetailsViewController.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// View Controllers
#import "DetailsViewController.h"

// Frameworks
@import Parse;
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameLabel.text = self.post.author.username;
    self.postTextLabel.text = self.post.postText;
    
    // Profile Picture
    PFFileObject *profilePictureObj = self.post.author[@"profilePicture"];
    NSURL *url = [NSURL URLWithString:profilePictureObj.url];
    [self.profilePicture setImageWithURL:url];
    
    // Like Button Count
    NSString *likeCount = [NSString stringWithFormat:@"%@", self.post.likeCount];
    [self.likeButton setTitle:likeCount forState:UIControlStateNormal];
    [self.likeButton setTitle:likeCount forState:UIControlStateHighlighted];
    [self.likeButton setTitle:likeCount forState:UIControlStateSelected];
    
    // Dislike Button Count
    NSString *dislikeCount = [NSString stringWithFormat:@"%@", self.post.dislikeCount];
    [self.dislikeButton setTitle:dislikeCount forState:UIControlStateNormal];
    [self.dislikeButton setTitle:dislikeCount forState:UIControlStateHighlighted];
    [self.dislikeButton setTitle:dislikeCount forState:UIControlStateSelected];
    
    // Show or hide edit/delete button if owner or not
    if ([self.post.author.username isEqualToString:PFUser.currentUser.username]) {
        self.editButton.hidden = NO;
        self.deleteButton.hidden = NO;
    } else {
        self.editButton.hidden = YES;
        self.deleteButton.hidden = YES;
    }
    
    
    // Show or hide post location button if has location or not
    if (self.post.latitude && self.post.longitude && !self.post.hideLocation) {
        self.pinLocationButton.hidden = NO;
    } else {
        self.pinLocationButton.hidden = YES;
    }
}

/* TODO: Implement navigation to Map's Screen with a specific zoom on the posts location
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
