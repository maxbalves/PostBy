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
#import "Post.h"

// Scene Delegate
#import "SceneDelegate.h"

@interface ComposeViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITextView *postTextField;
@property (strong, nonatomic) IBOutlet UIButton *postButton;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSNumber *latitude;
@property (nonatomic) NSNumber *longitude;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpUI];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    
    self.latitude = nil;
    self.longitude = nil;
    
    [self.locationManager requestWhenInUseAuthorization];
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
    }
}

- (void)setUpUI {
    self.postTextField.text = @"";
    
    // Setting up the border of our UITextView
    self.postTextField.layer.borderWidth = 0.5;
    self.postTextField.layer.borderColor = [[UIColor grayColor] CGColor];
    self.postTextField.layer.cornerRadius = 5.0;
}

- (IBAction)sendPost:(id)sender {
    // Prevent user from sharing more than once if clicking multiple times on share
    self.postButton.userInteractionEnabled = NO;
    
    // Location will be necessary to show around other users but can be opted if exact or not
    if (![CLLocationManager locationServicesEnabled] || !self.latitude || !self.longitude) {
        [self showAlertWithTitle:@"Location Required" message:@"Location services are required in order to share posts."];
        self.postButton.userInteractionEnabled = YES;
        return;
    }
    
    [Post postWithText:self.postTextField.text withLat:self.latitude withLong:self.longitude withCompletion:^(BOOL succeeded, NSError *error) {
        [PFUser.currentUser fetch];
        if (succeeded) {
            self.postTextField.text = @"";
            [self presentHome];
        } else if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
        self.postButton.userInteractionEnabled = YES;
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

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.latitude = @(manager.location.coordinate.latitude);
    self.longitude = @(manager.location.coordinate.longitude);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error.localizedDescription);
}

// Dismiss keyboard when user taps on the screen
- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
}

@end
