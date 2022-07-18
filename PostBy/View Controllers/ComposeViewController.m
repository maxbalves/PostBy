//
//  ComposeViewController.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// View Controllers
#import "ComposeViewController.h"

// Frameworks
@import MapKit;
@import Parse;

// Views
#import "CheckBox.h"
#import "Post.h"

// Scene Delegate
#import "SceneDelegate.h"

@interface ComposeViewController ()

@property (strong, nonatomic) IBOutlet UITextView *postTextField;
@property (strong, nonatomic) IBOutlet UIButton *postButton;
@property (strong, nonatomic) IBOutlet CheckBox *hideLocationButton;
@property (strong, nonatomic) IBOutlet CheckBox *hideUsernameButton;
@property (strong, nonatomic) IBOutlet CheckBox *hideProfilePicButton;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpUI];
    
    // This is only used to ask the user for location access if they haven't given it yet
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint * _Nullable geoPoint, NSError * _Nullable error) {}];
}

- (void)setUpUI {
    if (self.postVMToUpdate != nil) {
        self.postTextField.text = self.postVMToUpdate.postText;
        if (self.postVMToUpdate.hideLocation)
            [self hideLocationTapped:nil];
        if (self.postVMToUpdate.hideUsername)
            [self hideUsernameTapped:nil];
        if (self.postVMToUpdate.hideProfilePic)
            [self hideProfilePicTapped:nil];
    } else {
        self.postTextField.text = @"";
    }
    
    // Setting up the border of our UITextView
    self.postTextField.layer.borderWidth = 0.5;
    self.postTextField.layer.borderColor = [[UIColor grayColor] CGColor];
    self.postTextField.layer.cornerRadius = 5.0;
}

- (void) updatePost {
    self.postButton.userInteractionEnabled = NO;
    
    NSString *newPostText = self.postTextField.text;
    BOOL newHideLocation = self.hideLocationButton.isChecked;
    BOOL newHideProfilePic = self.hideProfilePicButton.isChecked;
    BOOL newHideUsername = self.hideUsernameButton.isChecked;
    
    [self.postVMToUpdate updateWithText:newPostText hideLocation:newHideLocation hideUsername:newHideUsername hideProfilePic:newHideProfilePic];
    
    [self.postVMToUpdate.delegate didUpdatePost];
    
    self.postButton.userInteractionEnabled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendPost:(id)sender {
    if (self.postVMToUpdate != nil) {
        [self updatePost];
        return;
    }
    
    // Prevent user from sharing more than once if clicking multiple times on share
    self.postButton.userInteractionEnabled = NO;
    
    // Get user's location with PFGeoPoint
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint * _Nullable geoPoint, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
            [self showAlertWithTitle:@"Location Error" message:@"Location services are required in order to share posts."];
            self.postButton.userInteractionEnabled = YES;
            return;
        }
        
        // On success, create post
        [Post postWithText:self.postTextField.text withLocation:geoPoint hideLocation:self.hideLocationButton.isChecked hideUsername:self.hideUsernameButton.isChecked hideProfilePic:self.hideProfilePicButton.isChecked withCompletion:^(BOOL succeeded, NSError *error) {
            [PFUser.currentUser fetch];
            if (succeeded) {
                self.postTextField.text = @"";
                [self presentHome];
            } else if (error) {
                NSLog(@"Error: %@", error.localizedDescription);
            }
            self.postButton.userInteractionEnabled = YES;
        }];
    }];
}

- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:(UIAlertControllerStyleAlert)];

    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    
    // add the OK action to the alert controller
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) presentHome {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    SceneDelegate *mySceneDelegate = (SceneDelegate *) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
    mySceneDelegate.window.rootViewController = tabBarController;
}

// Dismiss keyboard when user taps on the screen
- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)hideLocationTapped:(id)sender {
    [self.hideLocationButton buttonTapped];
}

- (IBAction)hideUsernameTapped:(id)sender {
    [self.hideUsernameButton buttonTapped];
}

- (IBAction)hideProfilePicTapped:(id)sender {
    [self.hideProfilePicButton buttonTapped];
}

@end
