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

- (IBAction)showPostLocation:(id)sender {
    [self performSegueWithIdentifier:@"DetailsShowMap" sender:self.post];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailsShowMap"]) {
        MapViewController *mapVC = [segue destinationViewController];
        mapVC.postToShow = sender;
    }
}

@end
