//
//  DataViewController.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/27/22.
//

// Views
#import "DataTableViewCell.h"

// View Controllers
#import "DataViewController.h"

// View Model
#import "CommentViewModel.h"
#import "PostViewModel.h"

// Global Variables
#import "GlobalVars.h"

// Frameworks
@import Parse;

@interface DataViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UINavigationItem *navBar;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *arrayOfData;
@property (nonatomic) BOOL showComments;
@property (nonatomic) BOOL showPosts;

@property (nonatomic) int MAX_DATA_SHOWN;
@property (nonatomic) int ADDITIONAL_DATA;

@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.MAX_DATA_SHOWN = 10;
    self.ADDITIONAL_DATA = 10;
    
    self.showComments = [self shouldRelationShowComments:self.data[@"relation"]];
    self.showPosts = [self shouldRelationShowPosts:self.data[@"relation"]];
    
    NSString *title = [NSString stringWithFormat:@"Your %@", self.data[@"navTitle"]];
    [self.navBar setTitle:title];
    
    [self queryData];
}

- (void) queryData {
    PFRelation *relation = [PFUser.currentUser relationForKey:self.data[@"relation"]];
    PFQuery *query = [relation query];
    [query setLimit:self.MAX_DATA_SHOWN];
    [query includeKey:@"author"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (self.showComments) {
            self.arrayOfData = [CommentViewModel commentVMsWithArray:objects];
        } else if (self.showPosts) {
            self.arrayOfData = [PostViewModel postVMsWithArray:objects];
        }
        [self.tableView reloadData];
    }];
}

- (DataTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DataTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"DataTableViewCell" forIndexPath:indexPath];
    
    if (self.showComments) {
        cell.commentVM = self.arrayOfData[indexPath.row];
    } else if (self.showPosts) {
        cell.postVM = self.arrayOfData[indexPath.row];
    }
    
    return cell;
}

- (BOOL) shouldRelationShowPosts:(NSString *)relation {
    BOOL isLikesRelation = [relation isEqualToString:LIKES_RELATION];
    BOOL isDislikesRelation = [relation isEqualToString:DISLIKES_RELATION];
    BOOL isPostsRelation = [relation isEqualToString:POSTS_RELATION];
    return (isLikesRelation || isDislikesRelation || isPostsRelation);
}

- (BOOL) shouldRelationShowComments:(NSString *)relation {
    return ([relation isEqualToString:COMMENTS_RELATION]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfData.count;
}

// Infinite scrolling
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row + 1 == self.arrayOfData.count && self.arrayOfData.count == self.MAX_DATA_SHOWN) {
        self.MAX_DATA_SHOWN += self.ADDITIONAL_DATA;
        [self queryData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Prevents cell from having gray background due to being selected
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Perform the real delete action here. Note: you may need to check editing style
    //   if you do not perform delete only.
    NSLog(@"Deleted row.");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
