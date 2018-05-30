//
//  V2TopicCell.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/21.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2TopicCell.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import "UIImage+Tint.h"

#define kTitleLabelWidth (kScreenWidth - 56)

static CGFloat const kAvatarHeight          = 26.0f;
static CGFloat const kTitleFontSize         = 17.0f;
static CGFloat const kBottomFontSize        = 12.0f;

@interface V2TopicCell ()

@property (nonatomic, strong) UILabel     *stateLabel;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel     *descriptionLabel;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *replyCountLabel;

@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UILabel     *nodeLabel;
@property (nonatomic, strong) UILabel     *timeLabel;

@property (nonatomic, strong) UIView      *topLineView;
@property (nonatomic, strong) UIView      *borderLineView;

@property (nonatomic, assign) NSInteger   titleHeight;
@property (nonatomic, assign) NSInteger   descriptionHeight;

@end

@implementation V2TopicCell

#pragma mark --- init
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.clipsToBounds = YES ;
        self.backgroundColor = kBackgroundColorWhite ;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupViews] ;
    }
    return self ;
}

- (void)setupViews{
    self.stateLabel                         = [[UILabel alloc] initWithFrame:(CGRect){-7.5, -7.5, 15, 15}];
    self.stateLabel.clipsToBounds           = YES;
    self.stateLabel.transform               = CGAffineTransformMakeRotation(M_PI_4);
    self.stateLabel.font                    = [UIFont systemFontOfSize:4];
    self.stateLabel.textColor               = [UIColor whiteColor];
    [self addSubview:self.stateLabel];
    
    self.avatarImageView                    = [[UIImageView alloc] init];
    self.avatarImageView.contentMode        = UIViewContentModeScaleAspectFill;
    self.avatarImageView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.avatarImageView];
    
    self.titleLabel                         = [[UILabel alloc] init];
    self.titleLabel.backgroundColor         = [UIColor clearColor];
    self.titleLabel.font                    = [UIFont systemFontOfSize:kTitleFontSize];;
    self.titleLabel.numberOfLines           = 0;
    self.titleLabel.lineBreakMode           = NSLineBreakByTruncatingTail|NSLineBreakByCharWrapping;
    [self addSubview:self.titleLabel];
    
    self.replyCountLabel                    = [[UILabel alloc] init];
    self.replyCountLabel.backgroundColor    = [UIColor clearColor];
    self.replyCountLabel.textColor          = [UIColor whiteColor];
    self.replyCountLabel.font               = [UIFont systemFontOfSize:8];;
    self.replyCountLabel.textAlignment      = NSTextAlignmentCenter;
    [self addSubview:self.replyCountLabel];
    
    self.timeLabel                          = [[UILabel alloc] init];
    self.timeLabel.backgroundColor          = [UIColor clearColor];
    self.timeLabel.font                     = [UIFont systemFontOfSize:kBottomFontSize];;
    self.timeLabel.textAlignment            = NSTextAlignmentRight;
    [self addSubview:self.timeLabel];
    
    self.nameLabel                          = [[UILabel alloc] init];
    self.nameLabel.backgroundColor          = [UIColor clearColor];
    self.nameLabel.font                     = [UIFont boldSystemFontOfSize:kBottomFontSize];
    self.nameLabel.textAlignment            = NSTextAlignmentRight;
    [self addSubview:self.nameLabel];
    
    self.nodeLabel                          = [[UILabel alloc] init];
    self.nodeLabel.backgroundColor          = [UIColor clearColor];
    self.nodeLabel.font                     = [UIFont systemFontOfSize:kBottomFontSize];
    self.nodeLabel.textAlignment            = NSTextAlignmentCenter;
    self.nodeLabel.lineBreakMode            = NSLineBreakByTruncatingTail;
    self.nodeLabel.backgroundColor          = [UIColor colorWithWhite:0.000 alpha:0.040];
    [self addSubview:self.nodeLabel];
    
    self.topLineView                        = [[UIView alloc] init];
    [self addSubview:self.topLineView];
    
    self.borderLineView                     = [[UIView alloc] init];
    [self addSubview:self.borderLineView];
    
    self.timeLabel.alpha = 1.0;
    
    self.titleLabel.textColor               = kFontColorBlackDark;
    self.timeLabel.textColor                = kFontColorBlackLight;
    self.nameLabel.textColor                = kFontColorBlackBlue;
    self.nodeLabel.textColor                = kFontColorBlackLight;
    self.topLineView.backgroundColor        = kLineColorBlackDark;
    self.borderLineView.backgroundColor     = kLineColorBlackDark;
}

#pragma mark --- Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    self.topLineView.frame      = CGRectMake(0, 0, kScreenWidth, 0.5);
    self.topLineView.hidden     = !self.isTop;
    
    self.avatarImageView.frame  = (CGRect){kScreenWidth - 10 - kAvatarHeight, 13, kAvatarHeight, kAvatarHeight};
    self.titleLabel.frame       = CGRectMake(10, 15, kTitleLabelWidth, self.titleHeight);
    
    self.nodeLabel.origin       = CGPointMake(kScreenWidth - 10 - self.nodeLabel.width, self.height - 27);
    self.nameLabel.origin       = CGPointMake(self.nodeLabel.left - self.nameLabel.width - 3, self.height - 27);
    self.timeLabel.origin       = CGPointMake(10, self.height - 27);
    
    self.borderLineView.frame   = CGRectMake(0, self.frame.size.height-0.5, kScreenWidth, 0.5);
}

#pragma mark -- set Model
- (void)setModel:(V2Topic *)model{
    _model = model;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.topicCreator.memberAvatarNormal] placeholderImage:[UIImage imageNamed:@"default_avatar"]] ;
    
    self.replyCountLabel.text = model.topicReplyCount;
    self.titleLabel.text      = model.topicTitle;
    self.timeLabel.text       = model.topicCreatedDescription;
    [self.timeLabel sizeToFit];
    
    self.nameLabel.text       = model.topicCreator.memberName;
    [self.nameLabel sizeToFit];
    
    self.nodeLabel.text       = [NSString stringWithFormat:@"%@", model.topicNode.nodeTitle];
    [self.nodeLabel sizeToFit];
    self.nodeLabel.width      += 4;
    
    self.titleHeight          = ceil(model.titleHeight);
    self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
    
    // [self updateStatus];
}

#pragma mark --- Public Method
- (void)updateStatus {
    switch (self.model.state) {
        case V2TopicStateReadWithNewReply:
            self.stateLabel.backgroundColor = [UIColor colorWithRed:1.000 green:0.581 blue:0.312 alpha:0.800];
            break;
        case V2TopicStateReadWithReply:
            self.stateLabel.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.040];
            break;
        case V2TopicStateReadWithoutReply:
            self.stateLabel.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.040];
            break;
        case V2TopicStateUnreadWithReply:
            self.stateLabel.backgroundColor = [self stateColorWithReplyCount:[self.model.topicReplyCount integerValue]];
            break;
        case V2TopicStateUnreadWithoutReply:
            self.stateLabel.backgroundColor = [UIColor colorWithRed:0.318 green:0.782 blue:1.000 alpha:0.300];
            break;
        default:
            break;
    }
}


+ (CGFloat)heightWithTopic:(V2Topic *)model{
    NSInteger titleHeight = [model.topicTitle heightForFont:[UIFont systemFontOfSize:kTitleFontSize] width:kTitleLabelWidth] ;
    NSInteger bottomHeight = [model.topicNode.nodeName heightForFont:[UIFont systemFontOfSize:kBottomFontSize] width:CGFLOAT_MAX] + 1 ;
    CGFloat cellHieght = 8 + 13 * 2 + titleHeight +bottomHeight ;
    model.cellHeight = cellHieght ;
    model.titleHeight = titleHeight ;
    return cellHieght ;
}

#pragma mark --- Style
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

+ (CGFloat)getCellHeightWithTopic:(V2Topic *)model {
    if (model.cellHeight > 10) {
        return model.cellHeight;
    } else {
        return [self heightWithTopic:model];
    }
}

#pragma mark - Private Methods
- (UIColor *)stateColorWithReplyCount:(NSInteger)replyCount {
    CGFloat alpha = 0.6 + (CGFloat)replyCount * 0.02;
    UIColor *color = [UIColor colorWithRed:0.318 green:0.782 blue:1.000 alpha:alpha];
    return color;
}

@end
