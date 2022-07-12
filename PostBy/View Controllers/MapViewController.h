//
//  MapViewController.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// View Models
#import "PostViewModel.h"

// Frameworks
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MapViewController : UIViewController

@property (strong, nonatomic) PostViewModel *postVMtoShow;

@end

NS_ASSUME_NONNULL_END
