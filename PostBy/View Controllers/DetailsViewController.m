//
//  DetailsViewController.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// View Controllers
#import "DetailsViewController.h"
#import "MapViewController.h"

// Frameworks
@import Parse;
#import "UIImageView+AFNetworking.h"

// Scene Delegate
#import "SceneDelegate.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameLabel.text = self.postVM.post.author.username;
    self.postTextLabel.text = self.postVM.post.postText;
    self.postDateLabel.text = self.postVM.postDate;
    
    // Profile Picture
    [self.profilePicture setImageWithURL:self.postVM.profilePicUrl];
    
    [self refreshLikeDislikeUI];
    
    // Show or hide edit/delete button if owner or not
    self.editButton.hidden = !self.postVM.isAuthor;
    self.deleteButton.hidden = !self.postVM.isAuthor;
    
    // Show or hide post location button if has location or not
    self.pinLocationButton.hidden = !self.postVM.showsLocation;
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

- (IBAction)showPostLocation:(id)sender {
    [self performSegueWithIdentifier:@"DetailsShowMap" sender:self.postVM];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailsShowMap"]) {
        MapViewController *mapVC = [segue destinationViewController];
        mapVC.postVMtoShow = sender;
    }
}

@end
