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

// Views
#import "CommentTableViewCell.h"

// View Model
#import "CommentViewModel.h"
#import "PostViewModel.h"

// Frameworks
@import Parse;
#import "UIImageView+AFNetworking.h"

// Scene Delegate
#import "SceneDelegate.h"

@interface DetailsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSString *EDIT_SEGUE;
@property (strong, nonatomic) NSString *MAP_SEGUE;
@property (strong, nonatomic) NSString *COMMENT_SEGUE;

@property (strong, nonatomic) IBOutlet UITableView *commentsTableView;
@property (strong, nonatomic) NSMutableArray *commentVMsArray;

@property (nonatomic) int MAX_COMMENTS_SHOWN;
@property (nonatomic) int ADDITIONAL_COMMENTS;

@end

@implementation DetailsViewController

- (void) setPostVM:(PostViewModel *)postVM {
    postVM.delegate = self;
    _postVM = postVM;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.EDIT_SEGUE = @"EditPostSegue";
    self.MAP_SEGUE = @"DetailsShowMap";
    self.COMMENT_SEGUE = @"CommentPostSegue";
    
    [self setUpUI];
    
    self.commentsTableView.dataSource = self;
    self.commentsTableView.delegate = self;
    
    self.MAX_COMMENTS_SHOWN = 8;
    self.ADDITIONAL_COMMENTS = 8;
    
    // Create border to show separation from post
    self.commentsTableView.layer.borderColor = [[UIColor grayColor] CGColor];
    self.commentsTableView.layer.borderWidth = 0.5;
}

- (void) setUpUI {
    self.usernameLabel.text = self.postVM.username;
    self.postTextLabel.text = self.postVM.postText;
    self.postDateLabel.text = self.postVM.postDate;
    
    // Profile Picture
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / CORNER_RADIUS_DIV_CONST;
    if (self.postVM.profilePicUrl == nil) {
        [self.profilePicture setImage:[UIImage imageNamed:DEFAULT_PROFILE_PIC]];
    } else {
        [self.profilePicture setImageWithURL:self.postVM.profilePicUrl];
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
    [self queryComments];
}

- (void) queryComments {
    // construct query
    PFRelation *postCommentsRelation = [self.postVM.post relationForKey:COMMENTS_RELATION];
    PFQuery *query =[postCommentsRelation query];
    [query includeKeys:@[AUTHOR_FIELD, POST_FIELD]];
    [query orderByDescending:@"createdAt"];
    [query setLimit:self.MAX_COMMENTS_SHOWN];
    
    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.commentVMsArray = [CommentViewModel commentVMsWithArray:objects];
        [self.commentsTableView reloadData];
    }];
}

- (void) queryPostWithObjectId:(NSString *)objectId {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:POST_CLASS];
    [query includeKey:AUTHOR_FIELD];
    [query whereKey:@"objectId" equalTo:objectId];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            if (posts.count > 0) {
                self.postVM = [[PostViewModel alloc] initWithPost:posts[0]];
                [self setUpUI];
            } else {
                [self invalidPostAlert];
            }
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void) invalidPostAlert {
    NSString *title = @"Post Not Found";
    NSString *message = @"It's possible the post you are trying to access was deleted or invalid.";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    // create an Okay action
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.delegate accessedBadPostVM:self.postVM];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    // add the OK action to the alert controller
    [alert addAction:okayAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) didLoadLikeDislikeData {
    [self setButtonsUserInteractionTo:YES];
    [self refreshLikeDislikeUI];
}

- (void) didUpdatePost {
    [self setUpUI];
}

- (void) postNotFound:(PostViewModel *)postVM {
    [self invalidPostAlert];
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
    [self setButtonsUserInteractionTo:NO];
    
    [self.postVM likeButtonTap];
    [self refreshLikeDislikeUI];
}

- (IBAction)dislikeButtonTap:(id)sender {
    [self setButtonsUserInteractionTo:NO];
    
    [self.postVM dislikeButtonTap];
    [self refreshLikeDislikeUI];
}

- (IBAction)deleteButtonTap:(id)sender {
    NSString *title = @"Post Deletion";
    NSString *message = @"Are you sure you want to delete this post?";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

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
    
    // This is called to remove the post from map or timeline
    [self.delegate accessedBadPostVM:self.postVM];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) setButtonsUserInteractionTo:(BOOL)value {
    self.likeButton.userInteractionEnabled = value;
    self.dislikeButton.userInteractionEnabled = value;
    self.deleteButton.userInteractionEnabled = value;
    self.editButton.userInteractionEnabled = value;
}

- (IBAction)editPost:(id)sender {
    [self performSegueWithIdentifier:self.EDIT_SEGUE sender:self.postVM];
}

- (IBAction)showPostLocation:(id)sender {
    [self performSegueWithIdentifier:self.MAP_SEGUE sender:self.postVM];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Locally refreshes timeline/map with most updated version of post
    if (self.isMovingFromParentViewController) {
        [self.delegate updatePostVMWith:self.postVM];
    }
}

- (IBAction)commentButtonTap:(id)sender {
    [self performSegueWithIdentifier:self.COMMENT_SEGUE sender:self.postVM];
}

- (CommentTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentTableViewCell *cell = [self.commentsTableView dequeueReusableCellWithIdentifier:@"CommentTableViewCell" forIndexPath:indexPath];
    
    cell.commentVM = self.commentVMsArray[indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentVMsArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Prevents cell from having gray background due to being selected
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Infinite scrolling
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row + 1 == self.commentVMsArray.count && self.commentVMsArray.count == self.MAX_COMMENTS_SHOWN) {
        self.MAX_COMMENTS_SHOWN += self.ADDITIONAL_COMMENTS;
        [self queryComments];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:self.MAP_SEGUE]) {
        MapViewController *mapVC = [segue destinationViewController];
        mapVC.postVMtoShow = sender;
    } else if ([segue.identifier isEqualToString:self.EDIT_SEGUE]) {
        ComposeViewController *composeVC = [segue destinationViewController];
        composeVC.navigationItem.title = @"Edit";
        composeVC.postVMToUpdate = sender;
    } else if ([segue.identifier isEqualToString:self.COMMENT_SEGUE]) {
        ComposeViewController *composeVC = [segue destinationViewController];
        composeVC.navigationItem.title = @"Comment";
        composeVC.postVMToComment = sender;
    }
}

@end

