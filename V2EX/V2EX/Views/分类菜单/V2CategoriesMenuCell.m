//
//  V2CategoriesMenuCell.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/21.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2CategoriesMenuCell.h"

#define kFontColorBlack [UIColor colorWithWhite:0.000 alpha:0.550]
static CGFloat const kCellHeight = 36;
static CGFloat const kFontSize   = 17;

@interface V2CategoriesMenuCell ()

@property (nonatomic, strong) UILabel     *titleLabel;

@property (nonatomic, assign) BOOL cellHighlighted;

@end

@implementation V2CategoriesMenuCell

#pragma mark --- init
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    self.titleLabel                 = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor       = [UIColor colorWithWhite:0.000 alpha:0.740];
    self.titleLabel.textAlignment   = NSTextAlignmentLeft;
    self.titleLabel.font            = [UIFont systemFontOfSize:kFontSize];
    [self addSubview:self.titleLabel];
}

#pragma mark --- Style
- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.cellHighlighted = selected;
    } completion:nil];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (self.isSelected) {
        return;
    }
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.cellHighlighted = highlighted;
    } completion:nil];
}

- (void)setCellHighlighted:(BOOL)cellHighlighted {
    _cellHighlighted = cellHighlighted;
    if (cellHighlighted) {
        if (kSetting.theme == V2ThemeNight) {
            self.titleLabel.textColor = kFontColorBlackMid;
            self.backgroundColor = kMenuCellHighlightedColor;
        } else {
            self.titleLabel.textColor = kColorBlue;
            self.backgroundColor = kMenuCellHighlightedColor;
        }
    } else {
        if (kSetting.theme == V2ThemeNight) {
            self.titleLabel.textColor = kFontColorBlackMid;
            self.backgroundColor = [UIColor clearColor];
        } else {
            self.titleLabel.textColor = kFontColorBlackMid;
            self.backgroundColor = [UIColor clearColor];
        }
    }
}

#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.frame    = (CGRect){20, 0, 110, self.height};
}
#pragma mark - Data Methods
- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = self.title;
}

#pragma mark - Class Methods
+ (CGFloat)getCellHeight {
    return kCellHeight;
}


@end
