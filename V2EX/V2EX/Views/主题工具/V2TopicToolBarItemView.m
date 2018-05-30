//
//  V2TopicToolBarItemView.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/23.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2TopicToolBarItemView.h"

CGFloat const kItemHeight = 44.0;
CGFloat const kItemWidth  = 100.0;

@interface V2TopicToolBarItemView ()

@property (nonatomic, strong) UIButton    *backgroundButton;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel     *descriptionLabel;

@end

@implementation V2TopicToolBarItemView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setupViews] ;
    }
    return self ;
}

- (void)setupViews{
    self.backgroundButton                        = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self.backgroundButton setImage:[UIImage imageWithColor:[UIColor colorWithWhite:0.000 alpha:0.90] size:(CGSize){kItemWidth, kItemHeight}] forState:UIControlStateNormal] ;
    [self.backgroundButton setImage:[UIImage imageWithColor:[UIColor colorWithRed:0.309 green:0.737 blue:1.000 alpha:0.900] size:(CGSize){kItemWidth, kItemHeight}] forState:UIControlStateHighlighted] ;
    [self addSubview:self.backgroundButton];
    
    self.iconImageView                           = [[UIImageView alloc] init];
    self.iconImageView.userInteractionEnabled    = NO;
    self.iconImageView.contentMode               = UIViewContentModeScaleAspectFit;
    [self addSubview:self.iconImageView];
    
    self.descriptionLabel                        = [[UILabel alloc] init];
    self.descriptionLabel.userInteractionEnabled = NO;
    self.descriptionLabel.font                   = [UIFont systemFontOfSize:14.0];
    self.descriptionLabel.textAlignment          = NSTextAlignmentLeft;
    [self.descriptionLabel setTextColor:[UIColor whiteColor]];
    [self addSubview:self.descriptionLabel];
    
    // Handles
    @weakify(self);
    [self.backgroundButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        if (self.buttonPressedBlock) {
            self.buttonPressedBlock();
        }
    } forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Layout

- (void)layoutSubviews {
    self.size                     = (CGSize){kItemWidth, kItemHeight};
    self.backgroundButton.frame   = (CGRect){0, 0, self.size};
    self.iconImageView.frame      = (CGRect){4, 4, 36, 36};
    self.descriptionLabel.frame   = (CGRect){44, 4, 50, 20};
    self.descriptionLabel.centerY = self.height / 2;
}

#pragma mark - Setters

- (void)setItemTitle:(NSString *)itemTitle {
    _itemTitle = itemTitle;
    self.descriptionLabel.text = self.itemTitle;
}

- (void)setItemImage:(UIImage *)itemImage {
    _itemImage = itemImage;
    self.iconImageView.image = self.itemImage;
}

- (void)setBackgroundColorNormal:(UIColor *)backgroundColorNormal {
    _backgroundColorNormal = backgroundColorNormal;
    [self.backgroundButton setImage:[UIImage imageWithColor:backgroundColorNormal size:(CGSize){kItemWidth, kItemHeight}] forState:UIControlStateNormal];
}

- (void)setBackgroundColorHighlighted:(UIColor *)backgroundColorHighlighted {
    _backgroundColorHighlighted = backgroundColorHighlighted;
    [self.backgroundButton setImage:[UIImage imageWithColor:backgroundColorHighlighted size:(CGSize){kItemWidth, kItemHeight}] forState:UIControlStateHighlighted] ;
}


@end
