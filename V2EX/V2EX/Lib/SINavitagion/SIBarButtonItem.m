//
//  SIBarButtonItem.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "SIBarButtonItem.h"
#import "UIImage+Tint.h"
#import <BlocksKit/BlocksKit+UIKit.h>
#import <YYCategories/YYCategories.h>

static const CGFloat kBadgeWidth = 6;
@interface SIBarButtonItem ()

@property (nonatomic, strong) UIImage *buttonImage;
@property (nonatomic, strong) UILabel *badgeLabel;

@end

@implementation SIBarButtonItem

- (instancetype)init{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithTitle:(NSString *)title handler:(void (^)(id sender))action {
    if ([self init]) {
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:title forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [button setTitleColor:kNavigationBarTintColor forState:UIControlStateNormal];
        [button sizeToFit];
        button.height = 44;
        button.width += 30;
        button.centerY = 20 + 22;
        button.left = 0;
        self.view = button;
        [button bk_addEventHandler:^(id sender) {
            action(sender);
            [UIView animateWithDuration:0.2 animations:^{
                button.alpha = 1.0;
            }];
            
        } forControlEvents:UIControlEventTouchUpInside];
        [button bk_addEventHandler:^(id sender) {
            button.alpha = 0.3;
        } forControlEvents:UIControlEventTouchDown];
        [button bk_addEventHandler:^(id sender) {
            [UIView animateWithDuration:0.3 animations:^{
                button.alpha = 1.0;
            }];
        } forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpOutside|UIControlEventTouchDragOutside];
        
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image handler:(void (^)(id sender))action {
    if ([self init]) {
        self.buttonImage = image;
        image = image.imageForCurrentTheme;
        UIButton *button = [[UIButton alloc] init];
        [button setImage:image forState:UIControlStateNormal];
        [button setImage:image forState:UIControlStateHighlighted];
        [button sizeToFit];
        button.height = 44;
        button.width += 30;
        button.centerY = 20 + 22;
        button.left = 0;
        self.view = button;
        [button bk_addEventHandler:^(id sender) {
            action(sender);
            [UIView animateWithDuration:0.2 animations:^{
                button.alpha = 1.0;
            }];
        } forControlEvents:UIControlEventTouchUpInside];
        
        [button bk_addEventHandler:^(id sender) {
            button.alpha = 0.3;
        } forControlEvents:UIControlEventTouchDown];
        
        [button bk_addEventHandler:^(id sender) {
            [UIView animateWithDuration:0.3 animations:^{
                button.alpha = 1.0;
            }];
        } forControlEvents:UIControlEventTouchCancel|UIControlEventTouchUpOutside|UIControlEventTouchDragOutside];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if (enabled) {
        self.view.userInteractionEnabled = YES;
        self.view.alpha = 1.0;
    } else {
        self.view.userInteractionEnabled = NO;
        self.view.alpha = 0.3;
    }
    
}

- (void)setBadge:(NSString *)badge {
    _badge = badge;
    if (!self.badgeLabel && badge) {
        self.badgeLabel = [[UILabel alloc] init];
        self.badgeLabel.backgroundColor = [UIColor redColor];
        self.badgeLabel.textColor = [UIColor whiteColor];
        self.badgeLabel.hidden = YES;
        self.badgeLabel.font = [UIFont systemFontOfSize:5];
        self.badgeLabel.layer.cornerRadius = kBadgeWidth/2.0;
        self.badgeLabel.clipsToBounds = YES;
        [self.view addSubview:self.badgeLabel];
    }
    
    if (badge) {
        self.badgeLabel.hidden = NO;
    } else {
        self.badgeLabel.hidden = YES;
    }
    self.badgeLabel.frame = (CGRect){self.view.width - 15, 10, kBadgeWidth, kBadgeWidth};
    self.badgeLabel.text = badge;
}


#pragma mark - Notifications
- (void)didReceiveThemeChangeNotification {
    UIButton *button  = (UIButton *)self.view;
    [button setTitleColor:kNavigationBarTintColor forState:UIControlStateNormal];
    [button setImage:self.buttonImage.imageForCurrentTheme forState:UIControlStateNormal];
}

@end
