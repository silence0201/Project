//
//  V2LatestViewController.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2LatestViewController.h"
#import "SIEmptyTableView.h"
#import "V2LoginViewController.h"
#import "SINavigationController.h"
#import "V2TopicViewController.h"
#import "V2TopicCell.h"

@interface V2LatestViewController ()<UITableViewDelegate,UITableViewDataSource,UIViewControllerPreviewingDelegate>

@property (nonatomic,strong) SIBarButtonItem *leftBarItem ;

@property (nonatomic,strong) NSMutableArray<V2Topic *> *topicList ;
@property (nonatomic,assign) NSInteger pageCount ;

@property (nonatomic,strong) NSURLSessionDataTask *currentTask ;


@end

@implementation V2LatestViewController

#pragma mark --- init
- (void)loadView{
    [super loadView] ;
    [self setupTableView] ;
    [self setupNaviBarItems] ;
}

- (void)setupTableView{
    self.tableView                 = [[SIEmptyTableView alloc] initWithFrame:self.view.frame];
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    
    [self.view addSubview:self.tableView];
}

- (void)setupNaviBarItems{
    self.leftBarItem = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_menu_2"] handler:^(id sender) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshEnabled = NO ;
    self.pageCount = 1 ;
    self.naviItem.leftBarButtonItem = self.leftBarItem ;
    self.naviItem.title = @"最新" ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveIgnoreTopicSuccessNotification:) name:kIgnoreTopicSuccessNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLoginSuccessNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self beginRefresh] ;
    }] ;
    [[NSNotificationCenter defaultCenter] addObserverForName:kLogoutSuccessNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [_topicList removeAllObjects] ;
        self.tableView.title = @"查看最新消息需要登录" ;
        self.tableView.buttonTitle = @"登录" ;
        @weakify(self);
        self.tableView.emptyClickAction = ^(){
            @strongify(self) ;
            [self presentViewController:[V2LoginViewController new] animated:YES completion:nil] ;
        } ;
        [self.tableView reloadData] ;
    }] ;
    
    @weakify(self);
    self.loadMoreBlock = ^{
        @strongify(self) ;
        self.pageCount ++ ;
        [self loadDataWithPage:self.pageCount] ;
    } ;
    
    self.refreshBlock = ^{
        @strongify(self);
        [self loadDataWithPage:1] ;
    };
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

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
            [self loadDataWithPage:self.pageCount] ;
        } ;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self beginRefresh] ;
    });
}

- (void)loadDataWithPage:(NSInteger)pageIndex{
    if (self.currentTask) {
        [self.currentTask cancel] ;
    }
    self.pageCount = pageIndex ;
    @weakify(self);
     self.currentTask = [[V2DataManager manager] getTopicListRecentWithPage:pageIndex Success:^(NSArray<V2Topic *> *list) {
        @strongify(self);
        if (self.pageCount > 1) {
            NSMutableArray *newList = [self.topicList mutableCopy];
            [newList addObjectsFromArray:[list mutableCopy]] ;
            self.topicList = newList ;
            [self endLoadMore] ;
        }else{
            self.topicList = [list mutableCopy];
            [self endRefresh] ;
        }
    } failure:^(NSError *error) {
        @strongify(self);
        if (self.pageCount > 1) {
            [self endLoadMore];
        } else {
            [self endRefresh];
        }
    }] ;
}

- (void)setTopicList:(NSMutableArray<V2Topic *> *)topicList{
    if (_topicList.lastObject.topicId == topicList.lastObject.topicId && self.pageCount != 1) {
        [FFToast showToastWithTitle:@"没有更多的数据" message:nil iconImage:nil duration:2 toastType:FFToastTypeWarning] ;
    }else{
        _topicList = topicList ;
        [self.tableView reloadData];
    }

}

#pragma mark - Layout
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.hiddenEnabled = YES;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.topicList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    V2TopicCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[V2TopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4) {
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                [self registerForPreviewingWithDelegate:self sourceView:cell];
            }
        }
    }
    return [self setupCell:cell IndexPath:indexPath] ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self heightOfTopicCellForIndexPath:indexPath] ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    V2Topic *model = self.topicList[indexPath.row];
    V2TopicViewController *topicViewController = [[V2TopicViewController alloc] init];
    topicViewController.model = model;
    [self.navigationController pushViewController:topicViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -- setup Cell

- (V2TopicCell *)setupCell:(V2TopicCell *)cell IndexPath:(NSIndexPath *)indexPath {
    V2Topic *model = self.topicList[indexPath.row];
    cell.model = model;
    cell.isTop = !indexPath.row;
    return cell;
}

- (CGFloat)heightOfTopicCellForIndexPath:(NSIndexPath *)indexPath {
    V2Topic *model = self.topicList[indexPath.row];
    return [V2TopicCell getCellHeightWithTopic:model];
}

#pragma mark - Preview
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location  {
    
    CGPoint point = [previewingContext.sourceView convertPoint:location toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if ([self.presentedViewController isKindOfClass:[V2TopicViewController class]]) {
        return nil;
    } else {
        V2TopicViewController *topicVC = [[V2TopicViewController alloc] init];
        topicVC.model = self.topicList[indexPath.row];
        topicVC.preview = YES;
        return topicVC;
    }
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    V2TopicViewController *topicVC = (V2TopicViewController *)viewControllerToCommit;
    topicVC.preview = NO;
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
}


#pragma mark - Nofitications
- (void)didReceiveIgnoreTopicSuccessNotification:(NSNotification *)notification {
    V2Topic *model = notification.object;
    if ([model isKindOfClass:[V2Topic class]]) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        __block NSUInteger index = NSNotFound;
        [self.topicList enumerateObjectsUsingBlock:^(V2Topic *item, NSUInteger idx, BOOL *stop) {
            if ([item isKindOfClass:[V2Topic class]]) {
                if ([item.topicId integerValue] != [model.topicId integerValue]) {
                    [list addObject:item];
                } else {
                    index = idx;
                }
            }
        }];
        
        if (index != NSNotFound) {
            self.topicList = list;
        }
    }
    
}



@end
