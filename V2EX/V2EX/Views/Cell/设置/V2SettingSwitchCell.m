//
//  V2SettingSwitchCell.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/22.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2SettingSwitchCell.h"
#import "UIImage+Tint.h"

@interface V2SettingSwitchCell ()

@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, strong) UIImage *imageSelected;
@property (nonatomic, strong) UIImage *imageNormal;

@end


@implementation V2SettingSwitchCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageNormal = [[UIImage imageNamed:@"navi_done"] imageWithTintColor:kLineColorBlackLight];
        self.imageSelected = [[UIImage imageNamed:@"navi_done"] imageWithTintColor:kFontColorBlackDark];
        
        self.arrowImageView = [[UIImageView alloc] initWithImage:self.imageNormal];
        [self.arrowImageView sizeToFit];
        [self addSubview:self.arrowImageView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.pushSwitch.onTintColor = kFontColorBlackBlue;
    
    self.pushSwitch.frame = (CGRect){260, 10, 35, 24};
    self.pushSwitch.centerY = CGRectGetHeight(self.frame)/2.0f;
    
    self.arrowImageView.centerY = self.height / 2;
    self.arrowImageView.left =  kScreenWidth - 15 - self.arrowImageView.width;
}

- (void)setIsOn:(BOOL)isOn {
    _isOn = isOn;
    self.pushSwitch.on = isOn;
    if (isOn) {
        self.arrowImageView.image = self.imageSelected;
    } else {
        self.arrowImageView.image = self.imageNormal;
    }
}



#pragma mark - Notifications

- (void)didReceiveThemeChangeNotification {
    self.imageNormal = [[UIImage imageNamed:@"navi_done"] imageWithTintColor:kLineColorBlackLight];
    self.imageSelected = [[UIImage imageNamed:@"navi_done"] imageWithTintColor:kFontColorBlackDark];
}


@end
