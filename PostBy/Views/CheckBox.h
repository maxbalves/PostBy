//
//  CheckBox.h
//  PostBy
//
//  Created by Max Bagatini Alves on 7/13/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CheckBox : UIButton

@property (nonatomic) BOOL isChecked;
@property (strong, nonatomic) UIImage *checkedImg;
@property (strong, nonatomic) UIImage *uncheckedImg;

- (void) buttonTapped;

@end

NS_ASSUME_NONNULL_END
