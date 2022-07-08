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
    return self.post.author.username;
}

+ (MapPin *)createPinFromPost:(Post *)post {
    MapPin *pin = [MapPin new];
    pin.post = post;
    
    // BAD! (not async call to get data);
    PFFileObject *profilePicObj = [post.author valueForKey:@"profilePicture"];
    NSURL *imageURL = [NSURL URLWithString:profilePicObj.url];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    
    // Default every pin's image to be 50 x 50
    CGSize pinImgSize = CGSizeMake(50, 50);
    pin.profilePic = [pin resizeImage:[UIImage imageWithData:imageData] withSize:pinImgSize];
    // TODO: Look into dispatch_async solution!
    // dispatch_async()});
    
    pin.coordinate = CLLocationCoordinate2DMake(post.latitude.floatValue, post.longitude.floatValue);
    
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
