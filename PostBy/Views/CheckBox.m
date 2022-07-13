//
//  CheckBox.m
//  PostBy
//
//  Created by Max Bagatini Alves on 7/13/22.
//

#import "CheckBox.h"

@implementation CheckBox

- (void) awakeFromNib {
    [super awakeFromNib];
    
    self.checkedImg = [UIImage systemImageNamed:@"checkmark.circle.fill"];
    self.uncheckedImg = [UIImage systemImageNamed:@"circle"];
    
    self.isChecked = NO;
    [self updateButton];
}

- (void) updateButton {
    if (self.isChecked) {
        [self setButtonToImage:self.checkedImg];
    } else {
        [self setButtonToImage:self.uncheckedImg];
    }
}

- (void)setButtonToImage:(UIImage *)img {
    [self setImage:img forState:UIControlStateNormal];
    [self setImage:img forState:UIControlStateHighlighted];
    [self setImage:img forState:UIControlStateSelected];
}

- (void) buttonTapped {
    self.isChecked = !self.isChecked;
    [self updateButton];
}

@end
