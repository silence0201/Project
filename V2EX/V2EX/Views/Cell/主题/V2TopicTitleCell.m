//
//  V2TopicTitleCell.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/24.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2TopicTitleCell.h"

#define kTitleLabelWidth (kScreenWidth - 20)

static CGFloat const kAvatarHeight = 30.0f;
static CGFloat const kTitleFontSize = 18.0f;

@interface V2TopicTitleCell ()

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton    *avatarButton;
@property (nonatomic, strong) UILabel     *titleLabel;

@property (nonatomic, assign) NSInteger   titleHeight;

@end

@implementation V2TopicTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = kBackgroundColorWhite;
        self.titleLabel                         = [[UILabel alloc] init];
        self.titleLabel.backgroundColor         = [UIColor clearColor];
        self.titleLabel.textColor               = kFontColorBlackDark;
        self.titleLabel.font                    = [UIFont boldSystemFontOfSize:kTitleFontSize];;
        self.titleLabel.numberOfLines           = 0;
        self.titleLabel.lineBreakMode           = NSLineBreakByCharWrapping;
        [self addSubview:self.titleLabel];
        [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            self.backgroundColor = kBackgroundColorWhite;
            self.titleLabel.textColor = kFontColorBlackDark;
            self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
        }] ;
        
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self] ;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.avatarImageView.frame   = (CGRect){kScreenWidth - 10 - kAvatarHeight, 0, kAvatarHeight, kAvatarHeight};
    self.avatarButton.frame   = (CGRect){kScreenWidth - 10 - kAvatarHeight - 10, 0, kAvatarHeight + 20, kAvatarHeight + 20};
    self.titleLabel.frame        = CGRectMake(10, 15, kTitleLabelWidth, self.titleHeight);
    self.avatarImageView.centerY = self.height / 2.0;
    self.avatarButton.centerY = self.height / 2.0;
    self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
}

- (void)setModel:(V2Topic *)model {
    _model = model;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.topicCreator.memberAvatarNormal] placeholderImage:[UIImage imageNamed:@"default_avatar"] options:0];
    self.titleLabel.text = model.topicTitle;
    self.titleHeight = [model.topicTitle heightForFont:[UIFont systemFontOfSize:kTitleFontSize] width:kTitleLabelWidth] + 1;
}


#pragma mark - Class Methods
+ (CGFloat)getCellHeightWithTopic:(V2Topic *)model {
    NSInteger titleHeight = [model.topicTitle heightForFont:[UIFont systemFontOfSize:kTitleFontSize] width:kTitleLabelWidth] + 1 ;
    if (model.topicTitle.length > 0) {
        return titleHeight + 25;
    } else {
        return 0;
    }
}

@end
