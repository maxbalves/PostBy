//
//  SettingsViewController.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// Global Variables
#import "GlobalVars.h"

// Models
#import "Post.h"

// Frameworks
#import <CCDropDownMenus/ManaDropDownMenu.h>
@import Parse;
#import "UIImageView+AFNetworking.h"

// View Controllers
#import "DataViewController.h"
#import "LoginViewController.h"
#import "SettingsViewController.h"

// Scene Delegate
#import "SceneDelegate.h"

@interface SettingsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CCDropDownMenuDelegate>

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *createdOnLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;

@property (strong, nonatomic) IBOutlet UIButton *deleteAccButton;

@property (nonatomic) int DEFAULT_IMAGE_SIZE;

@property (nonatomic) int DELETE_CHOICE;

typedef NS_ENUM(NSUInteger, MenuChoices) {
    DELETE_LIKES,
    DELETE_DISLIKES,
    DELETE_POSTS,
    DELETE_COMMENTS,
    DELETE_ACCOUNT,
    INVALID_CHOICE
};

@property (strong, nonatomic) NSString *dataRelationField;
@property (strong, nonatomic) NSString *dataNavTitleField;

@property (strong, nonatomic) NSString *DATA_SEGUE;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataRelationField = @"relation";
    self.dataNavTitleField = @"navTitle";
    
    self.DATA_SEGUE = @"SettingsShowData";
    
    self.DEFAULT_IMAGE_SIZE = 500;
    self.usernameLabel.text = PFUser.currentUser.username;
    self.createdOnLabel.text = [self returnFormatedDateString:PFUser.currentUser.createdAt];
    
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / CORNER_RADIUS_DIV_CONST;
    
    PFFileObject *profilePicObj = [PFUser.currentUser valueForKey:PROFILE_PIC_FIELD];
    NSURL *url = [NSURL URLWithString:profilePicObj.url];
    [self.profilePicture setImageWithURL:url];

    self.DELETE_CHOICE = INVALID_CHOICE;
    [self createDropDown];
}

- (void)createDropDown {
    CGFloat width = 240;
    CGFloat height = 37;
    // We need to offset by the width/2 in order to centralize the menu
    CGFloat x = (CGRectGetWidth(self.view.frame) / 2) - (width / 2);
    CGFloat y = 450;
    CGRect frame = CGRectMake(x, y, width, height);
    ManaDropDownMenu *menu = [[ManaDropDownMenu alloc] initWithFrame:frame title:@"Choose data to delete"];
    menu.delegate = self;
    // Order based on enum above
    menu.textOfRows = @[@"Likes", @"Dislikes", @"Posts", @"Comments", @"Account"];
    menu.numberOfRows = menu.textOfRows.count;
    
    menu.activeColor = [UIColor systemBlueColor];
    menu.inactiveColor = [UIColor systemBlueColor];
    // Super light gray background
    menu.titleViewColor = [UIColor colorWithRed:(250/255.0) green:(250/255.0) blue:(250/255.0) alpha:1];
    
    [self.view addSubview:menu];
}

- (void)dropDownMenu:(CCDropDownMenu *)dropDownMenu didSelectRowAtIndex:(NSInteger)index {
    self.DELETE_CHOICE = (int)index;
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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    // create Camera action
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePickerVC animated:YES completion:nil];
        }
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
    PFFileObject *oldProfilePicture = [PFUser.currentUser valueForKey:PROFILE_PIC_FIELD];
    
    // Change profile picture & save to Parse DB
    [PFUser.currentUser setValue:newProfilePicture forKey:PROFILE_PIC_FIELD];
    [PFUser.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            // change profile pic image view
            [self.profilePicture setImage:editedImage];
        } else {
            [PFUser.currentUser setValue:oldProfilePicture forKey:PROFILE_PIC_FIELD];
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

- (IBAction)promptDataDeletion:(id)sender {
    NSString *title = @"Delete Data";
    NSString *message = @"Are you sure you want to continue?";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    // create Confirm action
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self deleteDataBasedOnChoice];
        if (self.DELETE_CHOICE != INVALID_CHOICE)
            [self promptOkAlertWithTitle:@"Done" Message:@"Deletion completed"];
    }];
    
    // add the Confirm action to the alert controller
    [alert addAction:confirmAction];
    
    // create/add the Cancel action to the alert controller
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) promptOkAlertWithTitle:(NSString *)title Message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];

    // create OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // Refresh timeline to remove any deleted data
        [self.delegate refreshPosts];
    }];
    
    // add the OK action to the alert controller
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) deleteDataBasedOnChoice {
    if (self.DELETE_CHOICE == DELETE_LIKES) {
        [self deleteLikes];
        [PFUser.currentUser fetch];
    } else if (self.DELETE_CHOICE == DELETE_DISLIKES) {
        [self deleteDislikes];
        [PFUser.currentUser fetch];
    } else if (self.DELETE_CHOICE == DELETE_POSTS) {
        [self deletePosts];
        [PFUser.currentUser fetch];
    } else if (self.DELETE_CHOICE == DELETE_COMMENTS) {
        [self deleteComments];
        [PFUser.currentUser fetch];
    } else if (self.DELETE_CHOICE == DELETE_ACCOUNT) {
        [self deleteAccount];
    } else {
        // Invalid choice
        [self promptOkAlertWithTitle:@"Invalid Choice" Message:@"Please choose what to delete first."];
    }
}

- (void) deleteAccount {
    // Delete user's posts, comments, likes, dislikes, and account
    NSDictionary *params = @{
        CLOUD_LIKES_RELATION : LIKES_RELATION,
        CLOUD_DISLIKES_RELATION : DISLIKES_RELATION,
        CLOUD_COMMENT_CLASS : COMMENT_CLASS,
        CLOUD_COMMENTS_RELATION : COMMENTS_RELATION,
        CLOUD_POST_CLASS : POST_CLASS,
        CLOUD_POSTS_RELATION : POSTS_RELATION,
        CLOUD_POST_FIELD : POST_FIELD,
        CLOUD_AUTHOR_FIELD : AUTHOR_FIELD,
        @"useMasterKey" : @true
    };
    
    [PFCloud callFunctionInBackground:CLOUD_DELETE_ACCOUNT_FUNC withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            // Log user out if successfully deleted everything
            [self logoutUser];
        }
    }];
}

- (void) deletePosts {
    // delete posts
    NSDictionary *params = @{
        CLOUD_LIKES_RELATION : LIKES_RELATION,
        CLOUD_DISLIKES_RELATION : DISLIKES_RELATION,
        CLOUD_COMMENT_CLASS : COMMENT_CLASS,
        CLOUD_COMMENTS_RELATION : COMMENTS_RELATION,
        CLOUD_POST_CLASS : POST_CLASS,
        CLOUD_POSTS_RELATION : POSTS_RELATION,
        CLOUD_POST_FIELD : POST_FIELD,
        CLOUD_AUTHOR_FIELD : AUTHOR_FIELD,
        @"useMasterKey" : @true
    };
    
    [PFCloud callFunctionInBackground:CLOUD_DELETE_POSTS_FUNC withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void) deleteLikes {
    // delete likes from user relation
     NSDictionary *params = @{
         CLOUD_LIKES_RELATION : LIKES_RELATION,
         @"useMasterKey" : @true
     };
    
     [PFCloud callFunctionInBackground:CLOUD_DELETE_LIKES_FUNC withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
         if (error) {
             NSLog(@"Error: %@", error.localizedDescription);
         }
     }];
}

- (void) deleteDislikes {
    // delete dislikes
     NSDictionary *params = @{
         CLOUD_DISLIKES_RELATION : DISLIKES_RELATION,
         @"useMasterKey" : @true
     };
    
     [PFCloud callFunctionInBackground:CLOUD_DELETE_DISLIKES_FUNC withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
         if (error) {
             NSLog(@"Error: %@", error.localizedDescription);
         }
     }];
}

- (void) deleteComments {
    // delete comments
    NSDictionary *params = @{
        CLOUD_COMMENTS_RELATION : COMMENTS_RELATION,
        CLOUD_COMMENT_CLASS : COMMENT_CLASS,
        CLOUD_AUTHOR_FIELD : AUTHOR_FIELD,
        CLOUD_POST_FIELD : POST_FIELD
    };
    
    [PFCloud callFunctionInBackground:CLOUD_DELETE_COMMENTS_FUNC withParameters:params block:^(id  _Nullable object, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void) logoutUser {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
        LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        SceneDelegate *mySceneDelegate = (SceneDelegate *) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
        mySceneDelegate.window.rootViewController = loginVC;
    }];
}

- (IBAction)viewPostsTap:(id)sender {
    NSDictionary *data = @{
        self.dataNavTitleField : @"Posts",
        self.dataRelationField : POSTS_RELATION
    };
    
    [self performSegueWithIdentifier:self.DATA_SEGUE sender:data];
}

- (IBAction)viewCommentsTap:(id)sender {
    NSDictionary *data = @{
        self.dataNavTitleField : @"Comments",
        self.dataRelationField : COMMENTS_RELATION
    };
    
    [self performSegueWithIdentifier:self.DATA_SEGUE sender:data];
}

- (IBAction)viewLikesTap:(id)sender {
    NSDictionary *data = @{
        self.dataNavTitleField : @"Likes",
        self.dataRelationField : LIKES_RELATION
    };
    
    [self performSegueWithIdentifier:self.DATA_SEGUE sender:data];
}

- (IBAction)viewDislikesTap:(id)sender {
    NSDictionary *data = @{
        self.dataNavTitleField : @"Dislikes",
        self.dataRelationField : DISLIKES_RELATION
    };
    
    [self performSegueWithIdentifier:self.DATA_SEGUE sender:data];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:self.DATA_SEGUE]) {
        DataViewController *dataVC = [segue destinationViewController];
        NSDictionary *data = sender;
        dataVC.data = data;
    }
}

@end
