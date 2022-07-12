//
//  MapPin.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/7/22.
//

// Frameworks
#import <Foundation/Foundation.h>
@import MapKit;

// View Models
#import "PostViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface MapPin : NSObject <MKAnnotation>

@property (strong, nonatomic) UIImage *profilePic;
@property (strong, nonatomic) PostViewModel *postVM;

+ (MapPin *)createPinFromPostVM:(PostViewModel *)postVM;

@end

NS_ASSUME_NONNULL_END
