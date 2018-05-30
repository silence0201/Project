//
//  SINavigationBar.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "SINavigationBar.h"
#import "SINavigationController.h"
#import <YYCategories/YYCategories.h>


static char const * const kNaviHidden = "kSPNaviHidden";
static char const * const kNaviBar = "kSPNaviBar";
static char const * const kNaviBarView = "kNaviBarView";

@implementation SINavigationBar{
    UIView *_lineView ;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = (CGRect){0, 0, kScreenWidth, 64};
        self.backgroundColor = kNavigationBarColor;
        _lineView = [[UIView alloc] initWithFrame:(CGRect){0, 64, kScreenWidth, 0.5}];
        _lineView.backgroundColor = kNavigationBarLineColor;
        [self addSubview:_lineView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
        
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)didReceiveThemeChangeNotification {
    self.backgroundColor = kNavigationBarColor;
    _lineView.backgroundColor = kNavigationBarLineColor;
}

@end

@implementation UIViewController (SINavigation)

- (BOOL)isNavigationBarHidden {
    return [objc_getAssociatedObject(self, kNaviHidden) boolValue];
}

- (void)setNavigationBarHidden:(BOOL)sc_navigationBarHidden {
    objc_setAssociatedObject(self, kNaviHidden, @(sc_navigationBarHidden), OBJC_ASSOCIATION_ASSIGN);
}

- (SINavigationItem *)naviItem {
    return objc_getAssociatedObject(self, kNaviBar);
}

- (void)setNaviItem:(SINavigationItem *)naviItem {
    objc_setAssociatedObject(self, kNaviBar, naviItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)naviBar {
    return objc_getAssociatedObject(self, kNaviBarView);
}

- (void)setNaviBar:(UIView *)naviBar {
    objc_setAssociatedObject(self, kNaviBarView, naviBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)createNavigationBar {
    return [SINavigationController createNavigationBarForViewController:self];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if (hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            self.naviBar.top = -44;
            for (UIView *view in self.naviBar.subviews) {
                view.alpha = 0.0;
            }
        } completion:^(BOOL finished) {
            self.navigationBarHidden = YES;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.naviBar.top = 0;
            for (UIView *view in self.naviBar.subviews) {
                view.alpha = 1.0;
            }
        } completion:^(BOOL finished) {
            self.navigationBarHidden = NO;
        }];
    }
}

- (SIBarButtonItem *)createBackItem {
    @weakify(self);
    return [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)naviBeginRefreshing {
    UIActivityIndicatorView *activityView;
    for (UIView *view in self.naviBar.subviews) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            activityView = (UIActivityIndicatorView *)view;
        }
        if ([view isEqual:self.naviItem.rightBarButtonItem.view]) {
            [view removeFromSuperview];
        }
    }
    if (!activityView) {
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView setColor:[UIColor blackColor]];
        activityView.frame = (CGRect){kScreenWidth - 42, 25, 35, 35};
        [self.naviBar addSubview:activityView];
    }
    [activityView startAnimating];
}


- (void)naviEndRefreshing {
    UIActivityIndicatorView *activityView;
    for (UIView *view in self.naviBar.subviews) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            activityView = (UIActivityIndicatorView *)view;
        }
    }
    if (self.naviItem.rightBarButtonItem) {
        [self.naviBar addSubview:self.naviItem.rightBarButtonItem.view];
    }
    [activityView stopAnimating];
}


@end
