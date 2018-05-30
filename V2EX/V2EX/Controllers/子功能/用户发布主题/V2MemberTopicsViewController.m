//
//  V2MemberTopicsViewController.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/21.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2MemberTopicsViewController.h"
#import "V2TopicViewController.h"

#import "V2TopicCell.h"
#import "SINavigationController.h"

@interface V2MemberTopicsViewController ()<UITableViewDataSource, UITableViewDelegate,UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) SIBarButtonItem *leftBarItem;

@property (nonatomic, strong) NSMutableArray<V2Topic *> *topicList;

@property (nonatomic, copy) NSURLSessionDataTask *currentTask;
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation V2MemberTopicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentPage = 1 ;
    [self setupNaviBar] ;
    [self setupTableView] ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveIgnoreTopicSuccessNotification:) name:kIgnoreTopicSuccessNotification object:nil];
    
    @weakify(self);
    self.refreshBlock = ^{
        @strongify(self);
        [self loadData:NO] ;
    } ;
    
    
    self.loadMoreBlock = ^{
        @strongify(self);
        [self loadData:YES] ;
    } ;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self] ;
}

- (void)setupNaviBar{
    @weakify(self);
    self.leftBarItem = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.naviItem.leftBarButtonItem = self.leftBarItem ;
}

- (void)setupTableView{
    self.tableView                 = [[SIEmptyTableView alloc] initWithFrame:self.view.frame];
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    [self.view addSubview:self.tableView];
}

- (void)loadData:(BOOL)isLoadMore{
    if(self.currentTask){
        [self.currentTask cancel] ;
    }
    
    NSInteger page = 1 ;
    if (isLoadMore) {
        page = ++ self.currentPage ;
    }
    @weakify(self);
    self.currentTask = [[V2DataManager manager] getMemberTopicListWithMember:self.model page:page Success:^(NSArray<V2Topic *> *list) {
        @strongify(self);
        if (isLoadMore) {
            NSMutableArray *newList = [self.topicList mutableCopy];
            [newList addObjectsFromArray:[list mutableCopy]] ;
            self.topicList = newList ;
            [self endLoadMore] ;
        }else{
            self.topicList = [list mutableCopy] ;
            [self endRefresh] ;
        }
    } failure:^(NSError *error) {
        @strongify(self);
        if (isLoadMore) {
            [self endLoadMore];
        } else {
            [self endRefresh];
        }
    }] ;
}

#pragma mark - Data

- (void)setTopicList:(NSMutableArray<V2Topic *> *)topicList{
    if ([_topicList.lastObject.topicId isEqualToString:topicList.lastObject.topicId] && self.currentPage != 1) {
        [FFToast showToastWithTitle:@"没有更多的数据" message:nil iconImage:nil duration:2 toastType:FFToastTypeWarning] ;
    }else{
        _topicList = topicList;
        if (_topicList.count == 0) {
            self.tableView.title = @"用户发布主题被隐藏或为空" ;
            self.tableView.buttonTitle = @"点击刷新" ;
        }else{
            self.tableView.title = @"刷新失败" ;
            self.tableView.buttonTitle = @"重新刷新" ;
        }
        [self.tableView reloadData];
    }

}

#pragma mark --- setup Cell
- (V2TopicCell *)setupCell:(V2TopicCell *)cell indexPath:(NSIndexPath *)indexPath{
    V2Topic *model = self.topicList[indexPath.row];
    cell.model = model;
    cell.isTop = !indexPath.row;
    return cell;
}

- (CGFloat)heightOfTopicCellForIndexPath:(NSIndexPath *)indexPath{
    V2Topic *model = self.topicList[indexPath.row];
    return [V2TopicCell getCellHeightWithTopic:model];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.topicList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightOfTopicCellForIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    V2TopicCell *cell = (V2TopicCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[V2TopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
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
    V2Topic *model = self.topicList[indexPath.row];
    V2TopicViewController *topicViewController = [[V2TopicViewController alloc] init];
    topicViewController.model = model;
    [self.navigationController pushViewController:topicViewController animated:YES];
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

#pragma mark - Notifications
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
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
    }
}


@end
