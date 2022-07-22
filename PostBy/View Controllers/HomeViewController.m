//
//  HomeViewController.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// Global Variables
#import "GlobalVars.h"

// View Controllers
#import "DetailsViewController.h"
#import "HomeViewController.h"
#import "LoginViewController.h"
#import "SettingsViewController.h"

// Frameworks
@import Parse;

// Views
#import "PostTableViewCell.h"

// View Models
#import "PostViewModel.h"

// Scene Delegate
#import "SceneDelegate.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource, DetailsViewControllerDelegate, PostTableViewCellDelegate, SettingsViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UISegmentedControl *sortControl;
@property (nonatomic) int NEWEST_SORT;
@property (nonatomic) int TRENDING_SORT;
@property (nonatomic) int QUERY_MILE_RADIUS;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSMutableArray *postVMsArray;
@property (strong, nonatomic) NSMutableArray *sortedPostVMsArray;

@property (nonatomic) int MAX_POSTS_SHOWN;
@property (nonatomic) int ADDITIONAL_POSTS;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.NEWEST_SORT = 0;
    self.TRENDING_SORT = 1;
    
    self.QUERY_MILE_RADIUS = 5;
    
    self.MAX_POSTS_SHOWN = 10;
    self.ADDITIONAL_POSTS = 10;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [self refreshPosts];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)refreshPosts {
    [self.refreshControl beginRefreshing];
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint * _Nullable geoPoint, NSError * _Nullable error) {
        if (error) {
            [self showAlertWithTitle:@"Location Error" message:@"Location services are required to find posts around you."];
            [self.refreshControl endRefreshing];
            return;
        }
        
        // construct query
        PFQuery *query = [PFQuery queryWithClassName:POST_CLASS];
        query.limit = self.MAX_POSTS_SHOWN;
        [query orderByDescending:@"createdAt"];
        [query includeKey:AUTHOR_FIELD];
        [query whereKey:LOCATION_FIELD nearGeoPoint:geoPoint withinMiles:self.QUERY_MILE_RADIUS];

        // fetch data asynchronously
        [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
            if (posts != nil) {
                self.postVMsArray = [PostViewModel postVMsWithArray:posts];
                [self createTrendingArray];
                [self.tableView reloadData];
                [self.refreshControl endRefreshing];
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    }];
}

- (void) createTrendingArray {
    self.sortedPostVMsArray = (NSMutableArray *)[self.postVMsArray sortedArrayUsingComparator:^NSComparisonResult(PostViewModel *obj1, PostViewModel *obj2) {
        if (obj1.post.likeCount.intValue == obj2.post.likeCount.intValue)
            return obj1.post.dislikeCount.intValue > obj2.post.dislikeCount.intValue;
        return obj1.post.likeCount.intValue < obj2.post.likeCount.intValue;
    }];
}

- (IBAction)sortControlChanged:(id)sender {
    [self createTrendingArray];
    [self.tableView reloadData];
}


- (IBAction)logoutUser:(id)sender {
    // PFUser.current() will now be nil
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        SceneDelegate *mySceneDelegate = (SceneDelegate *) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
        mySceneDelegate.window.rootViewController = loginVC;
    }];
}

- (PostTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PostTableViewCell" forIndexPath:indexPath];
    
    if (self.sortControl.selectedSegmentIndex == self.NEWEST_SORT) {
        cell.postVM = self.postVMsArray[indexPath.row];
    } else if (self.sortControl.selectedSegmentIndex == self.TRENDING_SORT) {
        cell.postVM = self.sortedPostVMsArray[indexPath.row];
    }
    
    cell.delegate = self;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.postVMsArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Prevents cell from having gray background due to being selected
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Infinite scrolling
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row + 1 == self.postVMsArray.count && self.postVMsArray.count == self.MAX_POSTS_SHOWN) {
        self.MAX_POSTS_SHOWN += self.ADDITIONAL_POSTS;
        [self refreshPosts];
    }
}

- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];

    // create a Try Again action
    UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self refreshPosts];
    }];
    
    // add the OK action to the alert controller
    [alert addAction:tryAgainAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) cellWithBadPostVM:(PostViewModel *)postVM {
    NSString *title = @"Post Not Found";
    NSString *message = @"It's possible the post you are trying to access was deleted or invalid.";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];

    // create an Okay action
    UIAlertAction *okayAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self accessedBadPostVM:postVM];
    }];
    // add the OK action to the alert controller
    [alert addAction:okayAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) accessedBadPostVM:(PostViewModel *)postVM {
    NSInteger count = [self.postVMsArray count];
    for (NSInteger index = (count - 1); index >= 0; index--) {
        PostViewModel *p = self.postVMsArray[index];
        if ([p.post.objectId isEqualToString:postVM.post.objectId]) {
            [self.postVMsArray removeObjectAtIndex:index];
        }
    }
    [self.tableView reloadData];
}

- (void) updatePostVMWith:(PostViewModel *)updatedVM {
    NSInteger count = [self.postVMsArray count];
    for (NSInteger index = (count - 1); index >= 0; index--) {
        PostViewModel *p = self.postVMsArray[index];
        if ([p.post.objectId isEqualToString:updatedVM.post.objectId]) {
            p.post = updatedVM.post;
            [p setPropertiesFromPost:p.post];
            
            // Likes / Dislikes
            p.isLiked = updatedVM.isLiked;
            p.isDisliked = updatedVM.isDisliked;
            [p reloadLikeDislikeData];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"HomeShowDetails"]) {
        DetailsViewController *detailsVC = [segue destinationViewController];
        detailsVC.delegate = self;
        detailsVC.postVM = self.postVMsArray[[self.tableView indexPathForCell:sender].row];
    } else if ([segue.identifier isEqualToString:@"HomeToSettings"]) {
        SettingsViewController *settingsVC = [segue destinationViewController];
        settingsVC.delegate = self;
    }
}

@end
