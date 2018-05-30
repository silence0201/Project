//
//  V2ActionItemView.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/24.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

extern CGFloat const kActionItemHeight;
extern CGFloat const kActionItemHeightTitle;
extern CGFloat const kActionItemWidth;
extern CGFloat const kActionTitleFontSize;

@interface V2ActionItemView : UIView

@property (nonatomic, copy) void (^actionBlock)(UIButton *button, UILabel *label);

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName;

@end
