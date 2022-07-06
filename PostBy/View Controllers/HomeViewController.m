//
//  HomeViewController.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// View Controllers
#import "HomeViewController.h"
#import "LoginViewController.h"

// Frameworks
@import Parse;

// Views
#import "PostTableViewCell.h"

// Scene Delegate
#import "SceneDelegate.h"

@interface HomeViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) NSArray *postsArray;
@property (nonatomic) int MAX_POSTS_SHOWN;

// TODO: Implement infinite scrolling feature

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.MAX_POSTS_SHOWN = 8;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshPosts) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [self refreshPosts];
}

- (void)refreshPosts {
    [self.refreshControl beginRefreshing];
    
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    query.limit = self.MAX_POSTS_SHOWN;
    [query orderByDescending:@"createdAt"];
    [query includeKeys:@[@"author"]];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.postsArray = posts;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
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
    cell.post = self.postsArray[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.postsArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Prevents cell from having gray background due to being selected
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/* TODO: Work on segue from home screen to details page
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
