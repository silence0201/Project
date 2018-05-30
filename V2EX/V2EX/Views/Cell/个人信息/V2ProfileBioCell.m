//
//  V2ProfileBioCell.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/21.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2ProfileBioCell.h"

static NSString *const kBioDefaultString = @"这家伙太懒了，什么也没留下";

@interface V2ProfileBioCell ()

@property (nonatomic, strong) UILabel *bioLabel;

@property (nonatomic, strong) UIView *topBorderLineView;
@property (nonatomic, strong) UIView *bottomBorderLineView;

@end

@implementation V2ProfileBioCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds                        = YES;
        self.selectionStyle                       = UITableViewCellSelectionStyleNone;
        
        self.bioLabel                             = [UILabel new];
        self.bioLabel.font                        = [UIFont systemFontOfSize:15.0f];
        self.bioLabel.numberOfLines               = 0;
        self.bioLabel.lineBreakMode               = NSLineBreakByWordWrapping;
        self.bioLabel.textAlignment               = NSTextAlignmentLeft;
        [self addSubview:self.bioLabel];
        
        self.topBorderLineView                    = [UIView new];
        [self addSubview:self.topBorderLineView];
        
        self.bottomBorderLineView                 = [UIView new];
        [self addSubview:self.bottomBorderLineView];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor                      = kBackgroundColorWhite;
    self.bioLabel.textColor                   = kFontColorBlackDark;
    self.topBorderLineView.backgroundColor    = kLineColorBlackDark;
    self.bottomBorderLineView.backgroundColor = kLineColorBlackDark;
    
    NSInteger height = [self.bioString heightForFont:[UIFont systemFontOfSize:15.0] width:kScreenWidth - 30 ] + 1 ;
    self.bioLabel.frame = (CGRect){15, 10, kScreenWidth - 30, height};

    self.topBorderLineView.frame = (CGRect){0, 0, kScreenWidth, 0.5};
    self.bottomBorderLineView.frame = (CGRect){0, CGRectGetHeight(self.frame) - 0.5, kScreenWidth, 0.5};
}

- (void)setBioString:(NSString *)bioString {
    _bioString = bioString;
    self.bioLabel.text = bioString;
}

#pragma mark - Class Methods
+ (CGFloat)getCellHeightWithBioString:(NSString *)bioString {
    NSInteger height = [bioString heightForFont:[UIFont systemFontOfSize:15.0] width:kScreenWidth - 30 ] + 20 +1 ;
    return height;
}


@end
