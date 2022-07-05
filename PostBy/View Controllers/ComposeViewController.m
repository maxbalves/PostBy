//
//  ComposeViewController.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// View Controllers
#import "ComposeViewController.h"

// Frameworks
@import Parse;

// Views
#import "Post.h"

// Scene Delegate
#import "SceneDelegate.h"

@interface ComposeViewController ()

@property (strong, nonatomic) IBOutlet UITextView *postTextField;
@property (strong, nonatomic) IBOutlet UIButton *postButton;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpUI];
}

- (void)setUpUI {
    // TODO: Remove this and clear TextView text when app is done!
    self.postTextField.text = @"";
    
    // Setting up the border of our UITextView
    self.postTextField.layer.borderWidth = 0.5;
    self.postTextField.layer.borderColor = [[UIColor grayColor] CGColor];
    self.postTextField.layer.cornerRadius = 5.0;
}

- (IBAction)sendPost:(id)sender {
    // Prevent user from sharing more than once if clicking multiple times on share
    self.postButton.userInteractionEnabled = NO;
    
    [Post postWithText:self.postTextField.text withCompletion:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            self.postTextField.text = @"";
            [self presentHome];
        } else if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        self.postButton.userInteractionEnabled = YES;
    }];
}

- (void) presentHome {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    SceneDelegate *mySceneDelegate = (SceneDelegate *) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
    mySceneDelegate.window.rootViewController = tabBarController;
}

@end
