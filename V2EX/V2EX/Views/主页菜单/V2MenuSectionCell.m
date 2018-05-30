//
//  V2MenuSectionCell.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2MenuSectionCell.h"
#import "UIImage+Tint.h"


static CGFloat const kCellHeight = 60;
static CGFloat const kFontSize   = 16;

@implementation V2MenuSectionCell{
    UIImageView *_iconImageView ;
    UILabel *_titleLabel ;
    
    UIImage *_normalImage ;
    UIImage *_highlightedImage ;
    UILabel *_badgeLabel ;
}

#pragma mark --- init
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone ;
        self.backgroundColor = [UIColor clearColor] ;
        [self configureViews] ;
    }
    return self ;
}

- (void)configureViews{
    _iconImageView              = [[UIImageView alloc] init];
    _iconImageView.contentMode  = UIViewContentModeScaleAspectFill;
    [self addSubview:_iconImageView];
    
    _titleLabel                 = [[UILabel alloc] init];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor       = kFontColorBlackMid;
    _titleLabel.textAlignment   = NSTextAlignmentLeft;
    _titleLabel.font            = [UIFont systemFontOfSize:kFontSize];
    [self addSubview:_titleLabel];
}

#pragma mark --- Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    _iconImageView.frame = (CGRect){30, 21, 18, 18};
    _titleLabel.frame    = (CGRect){85, 0, 110, self.bounds.size.height};
}

#pragma mark --- Style
- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated] ;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.cellHighlighted = selected;
    } completion:nil];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated] ;
    if (self.isSelected) return ;
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.cellHighlighted = highlighted;
    } completion:nil];
}

- (void)setCellHighlighted:(BOOL)cellHighlighted{
    _cellHighlighted = cellHighlighted ;
    if (cellHighlighted) {
        if (kSetting.theme == V2ThemeNight) {
            _titleLabel.textColor = kFontColorBlackMid;
            self.backgroundColor = kMenuCellHighlightedColor;
            _iconImageView.image = _normalImage;
        } else {
            _titleLabel.textColor = kColorBlue;
            self.backgroundColor = kMenuCellHighlightedColor;
            _iconImageView.image = _highlightedImage;
        }
    }else{
        if (kSetting.theme == V2ThemeNight) {
            _titleLabel.textColor = kFontColorBlackMid;
            self.backgroundColor = [UIColor clearColor];
            _iconImageView.image = _normalImage;
        } else {
            _titleLabel.textColor = kFontColorBlackMid;
            self.backgroundColor = [UIColor clearColor];
            _iconImageView.image = _normalImage;
        }
    }
}

#pragma mark --- Set
- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.text = title;
}

- (void)setImageName:(NSString *)imageName {
    _imageName = imageName;
    
    NSString *highlightedImageName = [self.imageName stringByAppendingString:@"_highlighted"];
    _highlightedImage= [[UIImage imageNamed:self.imageName] imageWithTintColor:kColorBlue];
    _normalImage  = [[UIImage imageNamed:highlightedImageName] imageWithTintColor:kFontColorBlackMid];
    _normalImage = _normalImage.imageForCurrentTheme ;
    _iconImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
}

- (void)setBadge:(NSString *)badge {
    _badge = badge;
    static const CGFloat kBadgeWidth = 6;
    if (!_badgeLabel && badge) {
        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.backgroundColor = [UIColor redColor];
        _badgeLabel.textColor = [UIColor whiteColor];
        _badgeLabel.hidden = YES;
        _badgeLabel.font = [UIFont systemFontOfSize:5];
        _badgeLabel.layer.cornerRadius = kBadgeWidth/2.0;
        _badgeLabel.clipsToBounds = YES;
        [self addSubview:_badgeLabel];
    }
    if (badge) {
        _badgeLabel.hidden = NO;
    } else {
        _badgeLabel.hidden = YES;
    }
    _badgeLabel.frame = (CGRect){80, 10, kBadgeWidth, kBadgeWidth};
    _badgeLabel.text = badge;
}

#pragma mark --- Class Method
+ (CGFloat)getCellHeight {
    return kCellHeight;
}



@end
