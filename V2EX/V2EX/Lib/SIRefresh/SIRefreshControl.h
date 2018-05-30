//
//  SIRefreshControl.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIEmptyTableView.h"

@interface SIRefreshControl : UIViewController<UIScrollViewDelegate>

@property (nonatomic, strong) SIEmptyTableView *tableView;

@property (nonatomic, assign, getter = isViewShowing)   BOOL viewShowing;
@property (nonatomic, assign, getter = isHiddenEnabled) BOOL hiddenEnabled;

@property (nonatomic, assign) CGFloat tableViewInsertTop;
@property (nonatomic, assign) CGFloat tableViewInsertBottom;

@property (nonatomic, assign, getter = isRefreshEnable) BOOL refreshEnabled;

@property (nonatomic, copy) void (^refreshBlock)();

- (void)beginRefresh;
- (void)endRefresh;

@property (nonatomic, copy) void (^loadMoreBlock)();

- (void)beginLoadMore;
- (void)endLoadMore;

@end
