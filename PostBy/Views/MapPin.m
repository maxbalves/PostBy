//
//  MapPin.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/7/22.
//

// Views
#import "MapPin.h"

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
    
    UIImage *img = nil;
    if (postVM.profilePicUrl != nil) {
        // BAD! (not async call to get data);
        // TODO: Look into dispatch_async solution!
        NSData *imageData = [NSData dataWithContentsOfURL:postVM.profilePicUrl];
        img = [UIImage imageWithData:imageData];
    } else {
        img = [UIImage imageNamed:@"profile_tab.png"];
    }
    
    pin.profilePic = [pin resizeImage:img withSize:pinImgSize];
    
    pin.coordinate = CLLocationCoordinate2DMake(postVM.latitude, postVM.longitude);
    
    return pin;
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
