//
//  MapPin.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/7/22.
//

// Frameworks
#import <Foundation/Foundation.h>
@import MapKit;

// Model
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface MapPin : NSObject <MKAnnotation>

@property (strong, nonatomic) UIImage *profilePic;
@property (strong, nonatomic) Post *post;

+ (MapPin *)createPinFromPost:(Post *)post;

@end

NS_ASSUME_NONNULL_END
