//
//  V2NotificationCell.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/23.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2NotificationCell.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "V2MemberViewController.h"

#define kTopLabelWidth (kScreenWidth - 70)
static CGFloat const kAvatarHeight = 30.0f;

@interface V2NotificationCell ()

@property (nonatomic, strong) UIImageView        *avatarImageView;
@property (nonatomic, strong) UIButton           *avatarButton;

@property (nonatomic, strong) UIView             *descriptionBackgroundView;
@property (nonatomic, strong) TTTAttributedLabel *topLabel;
@property (nonatomic, strong) TTTAttributedLabel *descriptionLabel;
@property (nonatomic, strong) UILabel            *timeLabel;

@property (nonatomic, strong) UIView             *topLineView;
@property (nonatomic, strong) UIView             *borderLineView;

@end

@implementation V2NotificationCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.selectionStyle = UITableViewCellSelectionStyleNone ;
        [self setupViews] ;
    }
    return self ;
}

- (void)setupViews{
    self.clipsToBounds = YES;
    
    self.descriptionBackgroundView                    = [[UIView alloc] init];
    self.descriptionBackgroundView.layer.cornerRadius = 5.0;
    self.descriptionBackgroundView.clipsToBounds      = YES;
    self.descriptionBackgroundView.alpha              = 0.5;
    [self addSubview:self.descriptionBackgroundView];
    
    self.avatarImageView                    = [[UIImageView alloc] init];
    self.avatarImageView.contentMode        = UIViewContentModeScaleAspectFill;
    self.avatarImageView.layer.cornerRadius = 3; //kAvatarHeight/2.0;
    self.avatarImageView.clipsToBounds      = YES;
    [self addSubview:self.avatarImageView];
    
    self.avatarButton                       = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.avatarButton];
    
    self.topLabel                           = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.topLabel.lineBreakMode             = NSLineBreakByWordWrapping;
    self.topLabel.textAlignment             = NSTextAlignmentLeft;
    self.topLabel.numberOfLines             = 3;
    [self addSubview:self.topLabel];
    
    self.descriptionLabel                   = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    self.descriptionLabel.lineBreakMode     = NSLineBreakByWordWrapping;
    self.descriptionLabel.textAlignment     = NSTextAlignmentLeft;
    self.descriptionLabel.numberOfLines     = 6;
    [self addSubview:self.descriptionLabel];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont systemFontOfSize:13.0];
    [self addSubview:self.timeLabel];
    
    self.topLineView                        = [[UIView alloc] init];
    [self addSubview:self.topLineView];
    
    self.borderLineView                     = [[UIView alloc] init];
    [self addSubview:self.borderLineView];
    
    // Handles
    @weakify(self);
    [self.avatarButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        V2MemberViewController *profileVC = [[V2MemberViewController alloc] init];
        profileVC.member = self.model.notificationMember;
        [self.navi pushViewController:profileVC animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor                           = kBackgroundColorWhite;
    self.descriptionBackgroundView.backgroundColor = kCellHighlightedColor;
    self.timeLabel.textColor                       = kFontColorBlackLight;
    self.topLineView.backgroundColor               = kLineColorBlackDark;
    self.borderLineView.backgroundColor            = kLineColorBlackDark;
    
    self.avatarImageView.frame = (CGRect){10, 12, kAvatarHeight, kAvatarHeight};
    self.avatarButton.frame = (CGRect){0, 0, kAvatarHeight + 15, kAvatarHeight + 20};
    
    self.topLabel.origin = (CGPoint){50, 10};
    self.descriptionLabel.origin = (CGPoint){50, 18 + self.topLabel.height};
    self.descriptionBackgroundView.frame = (CGRect){45, 16 + self.topLabel.height, self.descriptionLabel.width + 10, self.descriptionLabel.height + 6};
    
    self.timeLabel.origin = (CGPoint){kScreenWidth - self.timeLabel.width, self.height - 8 - self.timeLabel.height};
    
    self.topLineView.frame      = CGRectMake(0, 0, kScreenWidth, 0.5);
    self.topLineView.hidden     = !self.isTop;
    
    self.borderLineView.frame   = CGRectMake(0, self.frame.size.height-0.5, kScreenWidth, 0.5);
    
    self.avatarImageView.alpha  = kSetting.imageViewAlphaForCurrentTheme;
    
}

#pragma mark --- Data
- (void)setModel:(V2Notification *)model{
    _model = model;
    
    CGSize topSize = [TTTAttributedLabel sizeThatFitsAttributedString:model.notificationTopAttributedString withConstraints:(CGSize){kTopLabelWidth, CGFLOAT_MAX} limitedToNumberOfLines:3];
    self.topLabel.size = topSize;
    self.topLabel.width = kTopLabelWidth;
    self.topLabel.attributedText = model.notificationTopAttributedString;
    
    if (model.notificationContent) {
        CGSize descriptionSize = [TTTAttributedLabel sizeThatFitsAttributedString:model.notificationDescriptionAttributedString withConstraints:(CGSize){kTopLabelWidth, CGFLOAT_MAX} limitedToNumberOfLines:6];
        self.descriptionLabel.size = descriptionSize;
        self.descriptionLabel.attributedText = model.notificationDescriptionAttributedString;
        self.descriptionLabel.hidden = NO;
        self.descriptionBackgroundView.hidden = NO;
    } else {
        self.descriptionLabel.hidden = YES;
        self.descriptionBackgroundView.hidden = YES;
    }
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.notificationMember.memberAvatarNormal] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    
    self.timeLabel.text = model.notificationCreatedDescription;
    [self.timeLabel sizeToFit];
}

+ (CGFloat)getCellHeightWithNotification:(V2Notification *)model {
    
    CGSize topSize = [TTTAttributedLabel sizeThatFitsAttributedString:model.notificationTopAttributedString withConstraints:(CGSize){kTopLabelWidth, CGFLOAT_MAX} limitedToNumberOfLines:3];
    CGSize descriptionSize = CGSizeMake(0, 0);
    CGFloat offset = 0;
    if (model.notificationContent) {
        descriptionSize = [TTTAttributedLabel sizeThatFitsAttributedString:model.notificationDescriptionAttributedString withConstraints:(CGSize){kTopLabelWidth, CGFLOAT_MAX} limitedToNumberOfLines:6];
        offset = 11;
    }
    return topSize.height + descriptionSize.height + 20 + offset + 15 + 7;
}

#pragma mark - Selected style

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
    UIColor *backbroundColor = kBackgroundColorWhite;
    if (selected) {
        backbroundColor = kCellHighlightedColor;
        self.backgroundColor = backbroundColor;
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.backgroundColor = backbroundColor;
        } completion:^(BOOL finished) {
            [self setNeedsLayout];
        }];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    UIColor *backbroundColor = kBackgroundColorWhite;
    if (highlighted) {
        backbroundColor = kCellHighlightedColor;
    }
    [UIView animateWithDuration:0.1 animations:^{
        self.backgroundColor = backbroundColor;
    }];
    
}


@end
