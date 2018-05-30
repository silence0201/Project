//
//  V2TopicInfoCell.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/24.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2TopicInfoCell.h"
#import "V2MemberViewController.h"
#import "V2Helper.h"

static CGFloat const kAvatarHeight = 14.0f;
@interface V2TopicInfoCell ()

@property (nonatomic, strong) UILabel *byLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *nodeLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton    *avatarButton;

@end

@implementation V2TopicInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds                = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = kBackgroundColorWhite;
        
        self.avatarImageView                    = [[UIImageView alloc] init];
        self.avatarImageView.contentMode        = UIViewContentModeScaleAspectFill;
        self.avatarImageView.layer.cornerRadius = 2;
        self.avatarImageView.clipsToBounds      = YES;
        self.avatarImageView.size               = CGSizeMake(kAvatarHeight, kAvatarHeight);
        self.avatarImageView.image              = [UIImage imageNamed:@"default_avatar"];
        [self addSubview:self.avatarImageView];
        
        self.avatarButton                       = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.avatarButton];
        
        self.nameLabel                    = [[UILabel alloc] init];
        self.nameLabel.backgroundColor    = [UIColor clearColor];
        self.nameLabel.textColor          = kFontColorBlackBlue;
        self.nameLabel.font               = [UIFont boldSystemFontOfSize:15.0];
        self.nameLabel.textAlignment      = NSTextAlignmentLeft;
        self.nameLabel.layer.cornerRadius = 3.0;
        self.nameLabel.clipsToBounds      = YES;
        [self addSubview:self.nameLabel];
        
        self.timeLabel                    = [[UILabel alloc] init];
        self.timeLabel.backgroundColor    = [UIColor clearColor];
        self.timeLabel.textColor          = kFontColorBlackLight;
        self.timeLabel.font               = [UIFont systemFontOfSize:14.0];;
        self.timeLabel.textAlignment      = NSTextAlignmentRight;
        [self addSubview:self.timeLabel];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            self.backgroundColor = kBackgroundColorWhite;
            self.nameLabel.textColor = kFontColorBlackBlue;
            self.timeLabel.textColor = kFontColorBlackLight;
        }] ;
        // Handles
        @weakify(self);
        [self.avatarButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            V2MemberViewController *profileVC = [[V2MemberViewController alloc] init];
            profileVC.member = self.model.topicCreator;
            [self.navi pushViewController:profileVC animated:YES];
        } forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self] ;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.timeLabel.left       = kScreenWidth - 10 - self.timeLabel.width;
    self.timeLabel.centerY = self.height / 2;
    self.avatarImageView.left         = 10;
    self.avatarImageView.centerY   = self.height / 2;
    self.nameLabel.left       = 10 + self.avatarImageView.width + 7;
    self.nameLabel.centerY = self.height / 2;
    
    self.avatarButton.frame = (CGRect){0, 0, self.nameLabel.left + self.nameLabel.width + 10, self.height};
    self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
}

- (void)setModel:(V2Topic *)model {
    _model = model;
    
    self.byLabel.text = @"by ";
    [self.byLabel sizeToFit];
    
    NSString *timeLabelString = @"";
    NSInteger replyCount = [self.model.topicReplyCount integerValue];
    if (replyCount == 1) {
        timeLabelString = [NSString stringWithFormat:@"%@ 回复", model.topicReplyCount];
    }
    if (replyCount > 1) {
        timeLabelString = [NSString stringWithFormat:@"%@ 回复", model.topicReplyCount];
    }
    if (model.topicCreated) {
        NSString *labelString = [V2Helper timeRemainDescriptionWithDateSP:model.topicCreated];
        if (replyCount > 0) {
            labelString = [labelString stringByAppendingString:@", "];
        }
        labelString = [labelString stringByAppendingString:timeLabelString];
        timeLabelString = labelString;
    }
    self.timeLabel.text = timeLabelString;
    [self.timeLabel sizeToFit];
    self.nameLabel.text = model.topicCreator.memberName;
    [self.nameLabel sizeToFit];
    self.nodeLabel.text = model.topicNode.nodeTitle;
    [self.nodeLabel sizeToFit];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.topicCreator.memberAvatarNormal] completed:nil];
}

#pragma mark - Class Methods
+ (CGFloat)getCellHeightWithTopic:(V2Topic *)model {
    if (model.topicTitle.length > 0) {
        return 28;
    } else {
        return 0;
    }
}



@end
