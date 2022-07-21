//
//  SettingsViewController.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/5/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SettingsViewControllerDelegate <NSObject>

- (void) refreshPosts;

@end

@interface SettingsViewController : UIViewController

@property (nonatomic, weak) id<SettingsViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
