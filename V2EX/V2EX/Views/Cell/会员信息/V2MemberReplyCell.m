//
//  V2MemberReplyCell.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/23.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2MemberReplyCell.h"
#import <TTTAttributedLabel/TTTAttributedLabel.h>

#define kTopLabelWidth (kScreenWidth - 20)
#define kContentLabelWidth (kScreenWidth - 40)

@interface V2MemberReplyCell ()

@property (nonatomic, strong) UIView             *descriptionBackgroundView;
@property (nonatomic, strong) TTTAttributedLabel *topLabel;
@property (nonatomic, strong) TTTAttributedLabel *descriptionLabel;
@property (nonatomic, strong) UILabel            *timeLabel;

@property (nonatomic, strong) UIView             *topLineView;
@property (nonatomic, strong) UIView             *borderLineView;

@end

@implementation V2MemberReplyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone ;
        self.backgroundColor = kBackgroundColorWhite ;
        [self setupViews] ;
    }
    return self ;
}

- (void)setupViews{
    self.clipsToBounds = YES ;
    
    self.descriptionBackgroundView                    = [[UIView alloc] init];
    self.descriptionBackgroundView.backgroundColor    = kCellHighlightedColor;
    self.descriptionBackgroundView.layer.cornerRadius = 5.0;
    self.descriptionBackgroundView.clipsToBounds      = YES;
    self.descriptionBackgroundView.alpha              = 0.5;
    [self addSubview:self.descriptionBackgroundView];
    
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
    self.timeLabel.textColor = kFontColorBlackLight;
    self.timeLabel.font = [UIFont systemFontOfSize:13.0];
    [self addSubview:self.timeLabel];
    
    self.topLineView                        = [[UIView alloc] init];
    self.topLineView.backgroundColor        = kLineColorBlackDark;
    [self addSubview:self.topLineView];
    
    self.borderLineView                     = [[UIView alloc] init];
    self.borderLineView.backgroundColor     = kLineColorBlackDark;
    [self addSubview:self.borderLineView];
}

#pragma mark --- Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    self.topLabel.origin = (CGPoint){10, 10};
    self.descriptionLabel.origin = (CGPoint){20, 18 + self.topLabel.height};
    self.descriptionBackgroundView.frame = (CGRect){15, 16 + self.topLabel.height, self.descriptionLabel.width + 10, self.descriptionLabel.height + 6};
    self.timeLabel.origin = (CGPoint){kScreenWidth - self.timeLabel.width - 10, self.height - 10 - self.timeLabel.height};
    self.topLineView.frame      = CGRectMake(0, 0, kScreenWidth, 0.5);
    self.topLineView.hidden     = !self.isTop;
    self.borderLineView.frame   = CGRectMake(0, self.frame.size.height-0.5, kScreenWidth, 0.5);
}

#pragma mark --- Data
- (void)setModel:(V2MemberReply *)model {
    _model = model;
    
    CGSize topSize = [TTTAttributedLabel sizeThatFitsAttributedString:model.memberReplyTopAttributedString withConstraints:(CGSize){kTopLabelWidth, CGFLOAT_MAX} limitedToNumberOfLines:3];
    self.topLabel.size = topSize;
    self.topLabel.width = kTopLabelWidth;
    self.topLabel.attributedText = model.memberReplyTopAttributedString;
    
    if (model.memberReplyContent) {
        CGSize descriptionSize = [TTTAttributedLabel sizeThatFitsAttributedString:model.memberReplyContentAttributedString withConstraints:(CGSize){kContentLabelWidth, CGFLOAT_MAX} limitedToNumberOfLines:6];
        self.descriptionLabel.size = descriptionSize;
        self.descriptionLabel.attributedText = model.memberReplyContentAttributedString;
        self.descriptionLabel.hidden = NO;
        self.descriptionBackgroundView.hidden = NO;
    } else {
        self.descriptionLabel.hidden = YES;
        self.descriptionBackgroundView.hidden = YES;
    }
    self.timeLabel.text = model.memberReplyCreatedDescription;
    [self.timeLabel sizeToFit];
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

#pragma mark - Class Methods

+ (CGFloat)getCellHeightWithMemberReply:(V2MemberReply *)model {
    CGSize topSize = [TTTAttributedLabel sizeThatFitsAttributedString:model.memberReplyTopAttributedString withConstraints:(CGSize){kTopLabelWidth, CGFLOAT_MAX} limitedToNumberOfLines:3];
    CGSize descriptionSize = CGSizeMake(0, 0);
    CGFloat offset = 0;
    if (model.memberReplyContent) {
        descriptionSize = [TTTAttributedLabel sizeThatFitsAttributedString:model.memberReplyContentAttributedString withConstraints:(CGSize){kContentLabelWidth, CGFLOAT_MAX} limitedToNumberOfLines:6];
        offset = 11;
    }
    return topSize.height + descriptionSize.height + 20 + offset + 15 + 7;
}

@end
