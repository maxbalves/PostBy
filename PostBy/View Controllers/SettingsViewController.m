//
//  SettingsViewController.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// Frameworks
@import Parse;
#import "UIImageView+AFNetworking.h"

// View Controllers
#import "SettingsViewController.h"

@interface SettingsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *createdOnLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;

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

@end
