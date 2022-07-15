//
//  MapPin.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/7/22.
//

// Views
#import "MapPin.h"

// Frameworks
#import "UIImageView+AFNetworking.h"

@interface MapPin ()

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation MapPin

- (NSString *)title {
    return self.postVM.username;
}

+ (MapPin *)createPinFromPostVM:(PostViewModel *)postVM {
    MapPin *pin = [MapPin new];
    pin.postVM = postVM;
    
    // Default every pin's image to be 50 x 50
    CGSize pinImgSize = CGSizeMake(50, 50);
    pin.profilePic = [pin resizeImageWithUrl:postVM.profilePicUrl withSize:pinImgSize];
    
    pin.coordinate = CLLocationCoordinate2DMake(postVM.latitude, postVM.longitude);
    
    return pin;
}

- (UIImage *)resizeImageWithUrl:(NSURL *)url withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    if (url == nil) {
        [resizeImageView setImage:[UIImage imageNamed:@"profile_tab.png"]];
    } else {
        [resizeImageView setImageWithURL:url];
    }
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return newImage;
}

@end
