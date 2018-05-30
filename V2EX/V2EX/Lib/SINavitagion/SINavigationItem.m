//
//  SINavigationItem.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "SINavigationItem.h"
#import "SINavigationBar.h"
#import <YYCategories/YYCategories.h>

@implementation SINavigationItem{
    __weak UIViewController *_viewController ;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    if (!title) {
        _titleLabel.text = @"";
        return;
    }
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        [_titleLabel setFont:[UIFont systemFontOfSize:17]];
        [_titleLabel setTextColor:kNavigationBarTintColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [_viewController.naviBar addSubview:_titleLabel];
    }
    _titleLabel.text = title;
    [_titleLabel sizeToFit];
    NSUInteger otherButtonWidth = self.leftBarButtonItem.view.width + self.rightBarButtonItem.view.width;
    _titleLabel.width = kScreenWidth - otherButtonWidth - 20;
    _titleLabel.centerY = 42;
    _titleLabel.centerX = kScreenWidth/2;
}

- (void)setLeftBarButtonItem:(SIBarButtonItem *)leftBarButtonItem {
    if (_viewController) {
        [_leftBarButtonItem.view removeFromSuperview];
        leftBarButtonItem.view.left = 0;
        leftBarButtonItem.view.centerY = 42;
        [_viewController.naviBar addSubview:leftBarButtonItem.view];
    }
    _leftBarButtonItem = leftBarButtonItem;
}

- (void)setRightBarButtonItem:(SIBarButtonItem *)rightBarButtonItem {
    if (_viewController) {
        [_rightBarButtonItem.view removeFromSuperview];
        rightBarButtonItem.view.left = kScreenWidth - rightBarButtonItem.view.width;
        rightBarButtonItem.view.centerY = 42;
        [_viewController.naviBar addSubview:rightBarButtonItem.view];
    }
    _rightBarButtonItem = rightBarButtonItem;
    
}

#pragma mark - Notifications

- (void)didReceiveThemeChangeNotification {
    [_titleLabel setTextColor:kNavigationBarTintColor];
}

@end
