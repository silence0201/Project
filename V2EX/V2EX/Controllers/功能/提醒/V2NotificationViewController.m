//
//  V2NotificationViewController.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2NotificationViewController.h"
#import "V2TopicViewController.h"
#import "V2NotificationCell.h"
#import "V2LoginViewController.h"
#import "SINavigationController.h"

@interface V2NotificationViewController ()<UITableViewDataSource, UITableViewDelegate, UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) NSMutableArray<V2Notification *> *notificationList;
@property (nonatomic, assign) NSInteger pageCount;

@property (nonatomic, strong) NSURLSessionDataTask *currentTask ;

@property (nonatomic, strong) SIBarButtonItem *leftBarItem;

@end

@implementation V2NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.pageCount = 1 ;
    [self setupNaviItem] ;
    [self setupTableViews] ;
    [self setupNotification] ;
    
    @weakify(self);
    self.refreshBlock = ^{
        @strongify(self);
        [self laodData:NO] ;
    } ;
    
    self.loadMoreBlock = ^{
        @strongify(self);
        [self laodData:YES] ;
    } ;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)setupTableViews{
    self.tableView                 = [[SIEmptyTableView alloc] initWithFrame:self.view.frame];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    
    if(![V2UserManager manager].user){
        self.tableView.title = @"查看最新消息需要登录" ;
        self.tableView.buttonTitle = @"登录" ;
        @weakify(self);
        self.tableView.emptyClickAction = ^(){
            @strongify(self) ;
            [self presentViewController:[V2LoginViewController new] animated:YES completion:nil] ;
        } ;
    }else{
        @weakify(self);
        self.tableView.emptyClickAction = ^(){
            @strongify(self) ;
            [self laodData:NO] ;
        } ;
    }
    
    
    [self.view addSubview:self.tableView];
}

- (void)setupNaviItem{
    self.leftBarItem = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_menu_2"] handler:^(id sender) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
    }];
    self.naviItem.leftBarButtonItem = self.leftBarItem ;
    self.naviItem.title = @"提醒" ;
}

- (void)setupNotification{
    [[NSNotificationCenter defaultCenter]addObserverForName:kLoginSuccessNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self beginRefresh] ;
    }] ;
    
    [[NSNotificationCenter defaultCenter]addObserverForName:kLogoutSuccessNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self.notificationList removeAllObjects] ;
        [self.tableView reloadData] ;
    }] ;
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.hiddenEnabled = YES;
}

#pragma mark --- Data
- (void)laodData:(BOOL)isMore{
    if (self.currentTask) {
        [self.currentTask cancel] ;
    }
    NSInteger page = 1 ;
    if (isMore) {
        page = ++self.pageCount ;
    }
    self.pageCount = page ;
    @weakify(self);
    self.currentTask = [[V2DataManager manager] getUserNotificationWithPage:page success:^(NSArray<V2Notification *> *list) {
        @strongify(self);
        if(!isMore){
            self.notificationList = [list mutableCopy] ;
            [self endRefresh] ;
        }else{
            NSMutableArray *newList = [self.notificationList mutableCopy] ;
            [newList addObjectsFromArray:[list mutableCopy]] ;
            self.notificationList = newList ;
            [self endLoadMore] ;
        }
    } failure:^(NSError *error) {
        @strongify(self);
        if (!isMore) {
            [self endRefresh];
        } else {
            [self endLoadMore];
        }
    }] ;
}

#pragma mark - Setters
- (void)setNotificationList:(NSMutableArray<V2Notification *> *)notificationList {
    if (notificationList.lastObject.notificationId == _notificationList.lastObject.notificationId && self.pageCount != 1) {
        [FFToast showToastWithTitle:@"没有更多的数据" message:nil iconImage:nil duration:2 toastType:FFToastTypeWarning] ;
    }else{
        _notificationList = notificationList ;
        [self.tableView reloadData];
    }

}

#pragma mark --- TableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notificationList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    V2Notification *model = self.notificationList[indexPath.row];
    return [V2NotificationCell getCellHeightWithNotification:model];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    V2NotificationCell *cell = (V2NotificationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[V2NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.navi = self.navigationController;
        
        // register for 3D Touch (if available)
        if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4) {
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                [self registerForPreviewingWithDelegate:self sourceView:cell];
            }
        }
    }
    return [self setupCell:cell indexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    V2Notification *model = self.notificationList[indexPath.row];
    V2TopicViewController *topicViewController = [[V2TopicViewController alloc] init];
    topicViewController.model = model.notificationTopic;
    [self.navigationController pushViewController:topicViewController animated:YES];
}

#pragma mark --- setup Cell
- (V2NotificationCell *)setupCell:(V2NotificationCell *)cell indexPath:(NSIndexPath *)indexPath{
    if(self.notificationList.count < indexPath.row) return cell;
    V2Notification *model = self.notificationList[indexPath.row];
    cell.model = model;
    cell.top = !indexPath.row;
    return cell;
}

- (CGFloat)heightOfTopicCellForIndexPath:(NSIndexPath *)indexPath {
    V2Notification *model = self.notificationList[indexPath.row];
    return [V2NotificationCell getCellHeightWithNotification:model];
}

#pragma mark - Preview

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location  {
    CGPoint point = [previewingContext.sourceView convertPoint:location toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if ([self.presentedViewController isKindOfClass:[V2TopicViewController class]]) {
        return nil;
    } else {
        V2Notification *model = self.notificationList[indexPath.row];
        V2TopicViewController *topicVC = [[V2TopicViewController alloc] init];
        topicVC.model = model.notificationTopic;
        topicVC.preview = YES;
        return topicVC;
    }
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    V2TopicViewController *topicVC = (V2TopicViewController *)viewControllerToCommit;
    topicVC.preview = NO;
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
}


@end
