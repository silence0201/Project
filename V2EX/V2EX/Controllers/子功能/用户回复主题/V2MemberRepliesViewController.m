//
//  V2MemberRepliesViewController.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/21.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2MemberRepliesViewController.h"
#import "V2TopicViewController.h"
#import "SINavigationController.h"


#import "V2MemberReplyCell.h"

@interface V2MemberRepliesViewController ()<UITableViewDelegate,UITableViewDataSource,UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) NSMutableArray<V2MemberReply *> *memberReplyList;

@property (nonatomic, strong) NSURLSessionDataTask *currentTask ;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) SIBarButtonItem *leftBarItem;

@end

@implementation V2MemberRepliesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNaviItem];
    [self setupTableView];
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

- (void)setupNaviItem{
    @weakify(self);
    self.leftBarItem = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    self.naviItem.leftBarButtonItem = self.leftBarItem ;
    self.naviItem.title = [NSString stringWithFormat:@"%@的回复",self.memberName] ;
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
        page = ++self.currentPage ;
    }
    @weakify(self);
    self.currentTask = [[V2DataManager manager] getUserReplyWithUsername:self.memberName page:page success:^(NSArray<V2MemberReply *> *list) {
        @strongify(self);
        if (isLoadMore) {
            NSMutableArray *newList = [self.memberReplyList mutableCopy];
            [newList addObjectsFromArray:[list mutableCopy]] ;
            self.memberReplyList = newList ;
            [self endLoadMore] ;
        }else{
            self.memberReplyList = [list mutableCopy] ;
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


- (void)setMemberReplyList:(NSMutableArray<V2MemberReply *> *)memberReplyList{
    if([_memberReplyList.lastObject.memberReplyTopic.topicId isEqualToString:memberReplyList.lastObject.memberReplyTopic.topicId] &&
       [_memberReplyList.lastObject.memberReplyContent isEqualToString:memberReplyList.lastObject.memberReplyContent] && self.currentPage != 1 ){
        [FFToast showToastWithTitle:@"没有更多的数据" message:nil iconImage:nil duration:2 toastType:FFToastTypeWarning] ;
    }else{
        _memberReplyList = memberReplyList ;
        if (_memberReplyList.count == 0) {
            self.tableView.title = @"用户发布主题被隐藏或为空" ;
            self.tableView.buttonTitle = @"点击刷新" ;
        }else{
            self.tableView.title = @"刷新失败" ;
            self.tableView.buttonTitle = @"重新刷新" ;
        }
        [self.tableView reloadData] ;
    }

}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.memberReplyList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    V2MemberReply *model = self.memberReplyList[indexPath.row];
    return [V2MemberReplyCell getCellHeightWithMemberReply:model];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    V2MemberReplyCell *cell = (V2MemberReplyCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[V2MemberReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        // register for 3D Touch (if available)
        if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4) {
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                [self registerForPreviewingWithDelegate:self sourceView:cell];
            }
        }
    }
    V2MemberReply *model = self.memberReplyList[indexPath.row];
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    V2MemberReply *model = self.memberReplyList[indexPath.row];
    V2TopicViewController *topicViewController = [[V2TopicViewController alloc] init];
    topicViewController.model = model.memberReplyTopic;
    [self.navigationController pushViewController:topicViewController animated:YES];
}

#pragma mark - Preview

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location  {
    CGPoint point = [previewingContext.sourceView convertPoint:location toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if ([self.presentedViewController isKindOfClass:[V2TopicViewController class]]) {
        return nil;
    } else {
        V2MemberReply *model = self.memberReplyList[indexPath.row];
        V2TopicViewController *topicVC = [[V2TopicViewController alloc] init];
        topicVC.model = model.memberReplyTopic;
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
