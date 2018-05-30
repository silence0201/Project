//
//  V2ActionItemView.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/24.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2ActionItemView.h"

CGFloat const kActionItemHeight = 80;
CGFloat const kActionItemHeightTitle = 100;
CGFloat const kActionItemWidth = 50.;
CGFloat const kActionTitleFontSize = 11;

@interface V2ActionItemView ()

@property (nonatomic, strong) UIButton *imageButton;
@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation V2ActionItemView

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName {
    if (self = [super initWithFrame:(CGRect){0, 0, kActionItemWidth, kActionItemHeight}]) {
        self.imageButton = [[UIButton alloc] init];
        [self.imageButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        self.imageButton.layer.cornerRadius = 5;
        self.imageButton.clipsToBounds = YES;
        [self addSubview:self.imageButton];
        
        if (title) {
            self.height = kActionItemHeightTitle;
            
            self.titleLabel = [[UILabel alloc] init];
            self.titleLabel.font = [UIFont systemFontOfSize:kActionTitleFontSize];
            self.titleLabel.text = title;
            self.titleLabel.textColor = kFontColorBlackLight;
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:self.titleLabel];
            
            self.imageButton.frame = (CGRect){0, 15, kActionItemWidth, kActionItemWidth};
            self.titleLabel.frame = (CGRect){0, 0, kActionItemWidth + 20, 15};
            self.titleLabel.bottom = self.bottom - 15;
            self.titleLabel.centerX = self.centerX;
        } else {
            self.height = kActionItemHeight;
            self.imageButton.frame = (CGRect){0, 15, kActionItemWidth, kActionItemWidth};
        }
    }
    return self;
}

- (void)setActionBlock:(void (^)(UIButton *button, UILabel *label))actionBlock {
    _actionBlock = actionBlock;
    [self.imageButton bk_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
    [self.imageButton bk_addEventHandler:^(id sender) {
        if (self.actionBlock) {
            self.actionBlock(self.imageButton, self.titleLabel);
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
}

@end
