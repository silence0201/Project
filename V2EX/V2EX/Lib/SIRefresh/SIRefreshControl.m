//
//  SIRefreshControl.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "SIRefreshControl.h"
#import "SIRefreshView.h"
#import "SINavigationBar.h"

#import <AFNetworking/AFNetworkReachabilityManager.h>

static CGFloat const kRefreshHeight = 44.0f;

@interface SIRefreshControl ()

@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UIView *tableFooterView;

@property (nonatomic, strong) SIRefreshView *refreshView;
@property (nonatomic, strong) SIRefreshView *loadMoreView;

@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) BOOL hadLoadMore;
@property (nonatomic, assign) CGFloat dragOffsetY;

@end

@implementation SIRefreshControl

#pragma mark --- init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.isLoadingMore = NO;
        self.isRefreshing = NO;
        self.hadLoadMore = NO;
        _viewShowing = NO;
        _hiddenEnabled = NO;
        self.tableViewInsertTop = 64;
        self.tableViewInsertBottom = 0;\
        _refreshEnabled = YES ;
    }
    return self;
}

- (void)loadView {
    [super loadView];

    self.tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0}];
    self.refreshView = [[SIRefreshView alloc] initWithFrame:(CGRect){0, -44, kScreenWidth, 44}];
    self.refreshView.timeOffset = 0.0;
    [self.tableHeaderView addSubview:self.refreshView];
    
    self.tableFooterView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0}];
    self.loadMoreView = [[SIRefreshView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 44}];
    self.loadMoreView.timeOffset = 0.0;
    [self.tableFooterView addSubview:self.loadMoreView];
}

#pragma mark --- Life Cycle
- (void)viewDidLoad{
    [super viewDidLoad] ;
    self.view.backgroundColor = kBackgroundColorWhiteDark;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated] ;
    if(self.isRefreshEnable){
        [self beginRefresh] ;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (nil != self.tableView.indexPathForSelectedRow) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
        if ([cell respondsToSelector:@selector(updateStatus)]) {
            [cell performSelector:@selector(updateStatus)];
        }
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
    
    @weakify(self)
    self.tableView.emptyClickAction = ^{
        @strongify(self)
        [self beginRefresh] ;
    } ;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
}

- (void)dealloc {
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark --- Layout
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableViewInsertTop, 0, self.tableViewInsertBottom, 0);
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Refresh
    CGFloat offsetY = -scrollView.contentOffset.y - self.tableViewInsertTop  - 25;
    
    self.refreshView.timeOffset = MAX(offsetY / 60.0, 0);
    
    // LoadMore
    if ((self.loadMoreBlock && scrollView.contentSize.height > 300) || !self.hadLoadMore) {
        self.loadMoreView.hidden = NO;
    } else {
        self.loadMoreView.hidden = YES;
    }
    
    if (scrollView.contentSize.height + scrollView.contentInset.top < kScreenHeight) {
        return;
    }
    
    CGFloat loadMoreOffset = - (scrollView.contentSize.height - self.view.bounds.size.height - scrollView.contentOffset.y + scrollView.contentInset.bottom);
    if (loadMoreOffset > 0) {
        self.loadMoreView.timeOffset = MAX(loadMoreOffset / 60.0, 0);
    } else {
        self.loadMoreView.timeOffset = 0;
    }
    // Handle hidden
    if (!_hiddenEnabled || !kSetting.navigationBarAutoHidden) {
        return;
    }
    CGFloat dragOffsetY = self.dragOffsetY - scrollView.contentOffset.y;
    CGFloat contentOffset = scrollView.contentOffset.y + scrollView.contentInset.top;
    if (contentOffset < 43) {
        [self setNavigationBarHidden:NO animated:YES];
        return;
    }
    if (dragOffsetY < - 30) {
        [self setNavigationBarHidden:YES animated:YES];
        return;
    }
    if (dragOffsetY > 110) {
        [self setNavigationBarHidden:NO animated:YES];
        return;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.dragOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // Refresh
    CGFloat refreshOffset = -scrollView.contentOffset.y - scrollView.contentInset.top;
    if (refreshOffset > 60 && self.refreshBlock && !self.isRefreshing) {
        [self beginRefresh];
    }
    // loadMore
    CGFloat loadMoreOffset = scrollView.contentSize.height - self.view.bounds.size.height - scrollView.contentOffset.y + scrollView.contentInset.bottom;
    if (loadMoreOffset < -60 && self.loadMoreBlock && !self.isLoadingMore && scrollView.contentSize.height > kScreenHeight) {
        [self beginLoadMore];
    }
}

#pragma mark - Public Methods
- (void)setRefreshBlock:(void (^)())refreshBlock {
    _refreshBlock = refreshBlock;
    if (self.tableView) {
        self.tableView.tableHeaderView = self.tableHeaderView;
    }
}

- (void)beginRefresh {    
    if (self.isRefreshing) {
        return;
    }
    self.isRefreshing = YES;
    [self.refreshView beginRefreshing];
    if (self.refreshBlock) {
        self.refreshBlock();
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            UIEdgeInsets newContentInset = self.tableView.contentInset;
            newContentInset.top = kRefreshHeight + self.tableViewInsertTop;
            self.tableView.contentInset = newContentInset;
            [self.tableView setContentOffset:(CGPoint){0,- (kRefreshHeight + self.tableViewInsertTop )} animated:NO];
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
        } completion:^(BOOL finished){
            
        }];
    });
}

- (void)endRefresh {
    [self.refreshView endRefreshing];
    self.isRefreshing = NO ;
    [UIView animateWithDuration:0.5 animations:^{
        UIEdgeInsets newContentInset = self.tableView.contentInset;
        newContentInset.top = self.tableViewInsertTop;
        self.tableView.contentInset = newContentInset;
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    }];
}

- (void)beginLoadMore {
    [self.loadMoreView beginRefreshing];
    self.isLoadingMore = YES;
    self.hadLoadMore = YES;
    if (self.loadMoreBlock) {
        self.loadMoreBlock();
    }
    [UIView animateWithDuration:0.2 animations:^{
        UIEdgeInsets newContentInset = self.tableView.contentInset;
        newContentInset.bottom = kRefreshHeight + self.tableViewInsertBottom;
        self.tableView.contentInset = newContentInset;
    }];
}

- (void)endLoadMore {
    [self.loadMoreView endRefreshing];
    self.isLoadingMore = NO;
    [UIView animateWithDuration:0.2 animations:^{
        UIEdgeInsets newContentInset = self.tableView.contentInset;
        newContentInset.bottom = + self.tableViewInsertBottom;
        self.tableView.contentInset = newContentInset;
    }];
}

- (void)setLoadMoreBlock:(void (^)())loadMoreBlock {
    _loadMoreBlock = loadMoreBlock;
    if (self.loadMoreBlock && self.tableView) {
        self.tableView.tableFooterView = self.tableFooterView;
    }
}

- (void)setIsRefreshing:(BOOL)isRefreshing{
    _isRefreshing = isRefreshing ;
    self.tableView.loading = isRefreshing ;
}

- (void)setIsLoadingMore:(BOOL)isLoadingMore{
    _isLoadingMore = isLoadingMore ;
    self.tableView.loading = isLoadingMore ;
}

#pragma mark - Notifications

- (void)didReceiveThemeChangeNotification {
    self.view.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    [self.tableView reloadData];
}

- (void)didReceiveStatusBarTappedNotification {
    [self.tableView scrollRectToVisible:(CGRect){0, 0, kScreenWidth, 0.1} animated:YES];
}

@end
