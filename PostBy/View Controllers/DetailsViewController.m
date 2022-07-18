//
//  DetailsViewController.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// Global Variables
#import "GlobalVars.h"

// View Controllers
#import "ComposeViewController.h"
#import "DetailsViewController.h"
#import "MapViewController.h"

// View Model
#import "PostViewModel.h"

// Frameworks
@import Parse;
#import "UIImageView+AFNetworking.h"

// Scene Delegate
#import "SceneDelegate.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController

- (void) setPostVM:(PostViewModel *)postVM {
    postVM.delegate = self;
    _postVM = postVM;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpUI];
}

- (void) setUpUI {
    self.usernameLabel.text = self.postVM.username;
    self.postTextLabel.text = self.postVM.postText;
    self.postDateLabel.text = self.postVM.postDate;
    
    // Profile Picture
    if (self.postVM.profilePicUrl != nil) {
        [self.profilePicture setImageWithURL:self.postVM.profilePicUrl];
    } else {
        [self.profilePicture setImage:[UIImage imageNamed:DEFAULT_PROFILE_PIC]];
    }
    
    [self refreshLikeDislikeUI];
    
    // Show or hide edit/delete button if owner or not
    self.editButton.hidden = !self.postVM.isAuthor;
    self.deleteButton.hidden = !self.postVM.isAuthor;
    
    // Show or hide post location button if has location or not
    self.pinLocationButton.hidden = self.postVM.hideLocation;
}

- (void) viewDidAppear:(BOOL)animated {
    [self queryPostWithObjectId:self.postVM.post.objectId];
}

- (void) queryPostWithObjectId:(NSString *)objectId {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKeys:@[@"author"]];
    [query whereKey:@"objectId" equalTo:objectId];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.postVM = [PostViewModel postVMsWithArray:posts][0];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void) didLoadLikeDislikeData {
    [self refreshLikeDislikeUI];
}

- (void) didUpdatePost {
    [self setUpUI];
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

- (IBAction)deleteButtonTap:(id)sender {
    NSString *title = @"Post Deletion";
    NSString *message = @"Are you sure you want to delete this post?";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];

    // create an Confirm action
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {[self deletePost];}];
    // add the Confirm action to the alert controller
    [alert addAction:confirmAction];
    
    // create & add an Cancel action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deletePost {
    [self setButtonsUserInteractionTo:NO];
    [self.postVM deletePost];
    [self setButtonsUserInteractionTo:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) setButtonsUserInteractionTo:(BOOL)value {
    self.likeButton.userInteractionEnabled = value;
    self.dislikeButton.userInteractionEnabled = value;
    self.deleteButton.userInteractionEnabled = value;
    self.editButton.userInteractionEnabled = value;
}

- (IBAction)editPost:(id)sender {
    [self performSegueWithIdentifier:@"EditPostSegue" sender:self.postVM];
}

- (IBAction)showPostLocation:(id)sender {
    [self performSegueWithIdentifier:@"DetailsShowMap" sender:self.postVM];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"DetailsShowMap"]) {
        MapViewController *mapVC = [segue destinationViewController];
        mapVC.postVMtoShow = sender;
    } else if ([segue.identifier isEqualToString:@"EditPostSegue"]) {
        ComposeViewController *composeVC = [segue destinationViewController];
        composeVC.postVMToUpdate = sender;
    }
}

@end
