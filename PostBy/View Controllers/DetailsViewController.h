//
//  DetailsViewController.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

// Models
#import "Post.h"

// Frameworks
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DetailsViewController : UIViewController

@property (strong, nonatomic) Post *post;

@end

NS_ASSUME_NONNULL_END
