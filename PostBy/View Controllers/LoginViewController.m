//
//  LoginViewController.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// Global Variables
#import "GlobalVars.h"

// View Controllers
#import "LoginViewController.h"

// Frameworks
@import Parse;

// Scene Delegate
#import "SceneDelegate.h"

@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)registerUser:(id)sender {
    // initialize user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    // validity check
    if ([self isBlankUsername:newUser.username password:newUser.password]) {
        // stop function if invalid
        return;
    }
    
    // set default profile picture
    UIImage *img = [UIImage imageNamed:DEFAULT_PROFILE_PIC];
    NSData *img_data = UIImagePNGRepresentation(img);
    PFFileObject *profilePicture = [PFFileObject fileObjectWithName:@"profilePicture.png" data:img_data];
    
    [newUser setValue:profilePicture forKey:PROFILE_PIC_FIELD];

    // call sign up function on object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
            if (error != nil) {
                NSLog(@"Error: %@", error.localizedDescription);
            } else {
                // manually segue to logged in view
                [self presentHome];
            }
    }];
}

- (IBAction)loginUser:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    // validity check
    if ([self isBlankUsername:username password:password]) {
        // stop function
        return;
    }
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
        } else {
            // display view controller that needs to shown after successful login
            [self presentHome];
        }
    }];
}

- (BOOL) isBlankUsername:(NSString *)username password:(NSString *)password {
    if ([username isEqualToString:@""]) {
        [self showAlertWithTitle:@"Username Required" message:@"Please enter your username"];
        return YES;
    } else if ([password isEqualToString:@""]) {
        [self showAlertWithTitle:@"Password Required" message:@"Please enter your password"];
        return YES;
    }
    return NO;
}

- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    // add the OK action to the alert controller
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
}

- (void) presentHome {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD bundle:nil];
    UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    SceneDelegate *mySceneDelegate = (SceneDelegate *) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
    mySceneDelegate.window.rootViewController = tabBarController;
}

@end
