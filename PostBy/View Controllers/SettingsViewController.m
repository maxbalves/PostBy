//
//  SettingsViewController.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// Models
#import "Post.h"

// Frameworks
@import Parse;
#import "UIImageView+AFNetworking.h"

// View Controllers
#import "LoginViewController.h"
#import "SettingsViewController.h"

// Scene Delegate
#import "SceneDelegate.h"

@interface SettingsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *createdOnLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;

@property (strong, nonatomic) IBOutlet UIButton *deleteAccButton;

@property (nonatomic) int DEFAULT_IMAGE_SIZE;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.DEFAULT_IMAGE_SIZE = 500;
    
    self.usernameLabel.text = PFUser.currentUser.username;
    self.createdOnLabel.text = [self returnFormatedDateString:PFUser.currentUser.createdAt];
    
    PFFileObject *profilePicObj = [PFUser.currentUser valueForKey:@"profilePicture"];;
    NSURL *url = [NSURL URLWithString:profilePicObj.url];
    [self.profilePicture setImageWithURL:url];
}

- (NSString *) returnFormatedDateString:(NSDate *)createdAt {
    NSDateFormatter *formatter = [NSDateFormatter new];
    
    // Configure the input format to parse the date string
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    
    // Configure output format
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    
    NSString *date = [NSString stringWithFormat:@"Created at %@", [formatter stringFromDate:createdAt]];
    
    return date;
}

- (IBAction)changePicture:(id)sender {
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    
    // Create alert for choosing Library or Camera or Cancel
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];

    // create Camera action
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    // add the Camera action to the alert controller
    [alert addAction:cameraAction];
    
    // create Library action
    UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }];
    // add the Library action to the alert controller
    [alert addAction:libraryAction];
    
    // create/add the Cancel action to the alert controller
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    // Edited Image picked by currentUser
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    
    // Makes sure new image is square and not too big to be stored by Parse
    CGSize size = CGSizeMake(self.DEFAULT_IMAGE_SIZE, self.DEFAULT_IMAGE_SIZE);
    UIImage *newImg = [self resizeImage:editedImage withSize:size];
    
    // Create PFFileObject to store new image
    NSData *newImageData = UIImagePNGRepresentation(newImg);
    PFFileObject *newProfilePicture = [PFFileObject fileObjectWithName:@"profilePicture.png" data:newImageData];
    
    // Old Image
    PFFileObject *oldProfilePicture = [PFUser.currentUser valueForKey:@"profilePicture"];
    
    // Change profile picture & save to Parse DB
    [PFUser.currentUser setValue:newProfilePicture forKey:@"profilePicture"];
    [PFUser.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            // change profile pic image view
            [self.profilePicture setImage:editedImage];
        } else {
            [PFUser.currentUser setValue:oldProfilePicture forKey:@"profilePicture"];
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
    
    // Dismiss UIImagePickerController to go back to your original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (IBAction)promptAccountDeletion:(id)sender {
    NSString *title = @"Delete Account";
    NSString *message = @"Are you sure you want to delete your account?";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    // create Confirm action
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {[self deleteAccount];}];
    
    // add the OK action to the alert controller
    [alert addAction:confirmAction];
    
    // create/add the Cancel action to the alert controller
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) deleteAccount {
    // delete posts
    PFRelation *postsRelation = [PFUser.currentUser relationForKey:@"posts"];
    NSArray *userPosts = [[postsRelation query] findObjects];
    for (Post *post in userPosts) {
        // get & delete this post's comments
        PFRelation *commentsRelation = [post relationForKey:@"comments"];
        NSArray *comments = [[commentsRelation query] findObjects];
        for (PFObject *comment in comments) {
            [comment delete];
        }
        
        [post delete];
    }
    
    // delete likes
    PFRelation *likesRelation = [PFUser.currentUser relationForKey:@"likes"];
    NSArray *likedPosts = [[likesRelation query] findObjects];
    for (Post *post in likedPosts) {
        // unlike the post
        [self unlikePost:post];
        
        // remove it from my relation
        [likesRelation removeObject:post];
    }
    [PFUser.currentUser save];
    
    // delete dislikes
    PFRelation *dislikesRelation = [PFUser.currentUser relationForKey:@"dislikes"];
    NSArray *dislikedPosts = [[dislikesRelation query] findObjects];
    for (Post *post in dislikedPosts) {
        // unlike the post
        [self undislikePost:post];
        
        // remove it from my relation
        [dislikesRelation removeObject:post];
    }
    [PFUser.currentUser save];
    
    // delete comments
    PFRelation *commentsRelation = [PFUser.currentUser relationForKey:@"comments"];
    NSArray *userComments = [[commentsRelation query] findObjects];
    for (PFObject *comment in userComments) {
        [comment delete];
    }
    
    // delete account
    [PFUser.currentUser delete];
    
    // log out
    [self logoutUser];
}

- (void) unlikePost:(Post *) post {
    PFRelation *postLikes = [post relationForKey:@"likes"];
    [postLikes removeObject:PFUser.currentUser];
    post.likeCount = @(post.likeCount.intValue - 1);
    [post save];
}

- (void) undislikePost:(Post *) post {
    PFRelation *postDislikes = [post relationForKey:@"dislikes"];
    [postDislikes removeObject:PFUser.currentUser];
    post.dislikeCount = @(post.dislikeCount.intValue - 1);
    [post save];
}

- (void) logoutUser {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        SceneDelegate *mySceneDelegate = (SceneDelegate *) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
        mySceneDelegate.window.rootViewController = loginVC;
    }];
}

@end
