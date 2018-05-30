//
//  V2NodeViewController.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/22.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2NodeViewController.h"

#import "V2TopicViewController.h"

#import "V2TopicToolBarItemView.h"
#import "V2TopicCell.h"
#import "SINavigationController.h"

@interface V2NodeViewController ()<UITableViewDelegate,UITableViewDataSource,UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) SIBarButtonItem *leftBarItem;
@property (nonatomic, strong) SIBarButtonItem *addBarItem;

@property (nonatomic, strong) UIView          *menuContainView;
@property (nonatomic, strong) UIView          *menuView;
@property (nonatomic, strong) UIButton        *menuBackgroundButton;

@property (nonatomic, strong) NSMutableArray<V2Topic *> *topicList;

@property (nonatomic, assign) NSInteger       pageCount;

@property (nonatomic, copy) NSURLSessionDataTask *currentTask ;

@property (nonatomic, assign) BOOL isMenuShowing;

@end

@implementation V2NodeViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    _pageCount = 1;
    [self setupNaviItems];
    [self setupTableView];
    [self setupMenuView];
    self.refreshEnabled = YES ;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveIgnoreTopicSuccessNotification:) name:kIgnoreTopicSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTopicCreateSuccessNotification) name:kTopicCreateSuccessNotification object:nil];
    @weakify(self);
    self.refreshBlock = ^{
       @strongify(self);
        [self loadData:NO] ;
    } ;
    
    self.loadMoreBlock = ^{
        @strongify(self);
        [self loadData:YES];
    } ;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated] ;
    self.refreshEnabled = NO ;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.menuContainView.frame = self.view.bounds;
    self.menuBackgroundButton.frame = self.menuContainView.bounds;
    
}

- (void)setupNaviItems{
    @weakify(self);
    self.leftBarItem = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    self.addBarItem = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_add"] handler:^(id sender) {
        @strongify(self);
        if (self.isMenuShowing) {
            [self hideMenuAnimated:YES];
        }else {
            [self showMenuAnimated:YES];
        }
    }];
    
    self.naviItem.leftBarButtonItem = self.leftBarItem ;
    self.naviItem.rightBarButtonItem = self.addBarItem ;
    self.naviItem.title = self.model.nodeTitle ;
}

- (void)setupTableView{
    self.tableView                 = [[SIEmptyTableView alloc] initWithFrame:self.view.frame];
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    [self.view addSubview:self.tableView];
    @weakify(self);
    self.tableView.emptyClickAction = ^(){
        @strongify(self) ;
        [self loadData:NO] ;
    } ;
}

- (void)setupMenuView{
    self.menuContainView = [[UIView alloc] init];
    self.menuContainView.userInteractionEnabled = NO;
    [self.view addSubview:self.menuContainView];
    
    self.menuBackgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuBackgroundButton.backgroundColor = [UIColor colorWithWhite:0.667 alpha:0];
    
    @weakify(self)
    UIPanGestureRecognizer *menuBGButtonPanGesture = [UIPanGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        [self hideMenuAnimated:NO];
    }];
    [self.menuBackgroundButton addGestureRecognizer:menuBGButtonPanGesture];
    [self.menuContainView addSubview:self.menuBackgroundButton];
    
    self.menuView = [[UIView alloc] init];
    self.menuView.alpha = 0.0;
    self.menuView.frame = (CGRect){200, 64, 130, 118};
    [self.menuContainView addSubview:self.menuView];
    
    UIView *topArrowView = [[UIView alloc] init];
    topArrowView.frame = (CGRect){87, 5, 10, 10};
    topArrowView.backgroundColor = [UIColor blackColor];
    topArrowView.transform = CGAffineTransformMakeRotation(M_PI_4);
    [self.menuView addSubview:topArrowView];
    
    UIView *menuBackgroundView = [[UIView alloc] init];
    menuBackgroundView.frame = (CGRect){10, 10, 100, 88};
    menuBackgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.90];
    menuBackgroundView.layer.cornerRadius = 5.0;
    menuBackgroundView.clipsToBounds = YES;
    [self.menuView addSubview:menuBackgroundView];
    
    NSArray *itemTitleArray = @[@"发帖", @"收藏"];
    NSArray *itemImageArray = @[@"icon_post", @"icon_fav"];
    
    void (^buttonHandleBlock)(NSInteger index) = ^(NSInteger index) {
        @strongify(self);
        if (index == 0) {
            V2TopicViewController *topicCreateVC = [[V2TopicViewController alloc] init];
            topicCreateVC.create = YES;
            V2Topic *topicModel = [[V2Topic alloc] init];
            topicModel.topicNode = self.model;
            topicCreateVC.model = topicModel;
            [self.navigationController pushViewController:topicCreateVC animated:YES];
        }
        
        if (index == 1) {
            [[V2DataManager manager] favNodeWithName:self.model.nodeName success:^(NSString *message) {
                NSString *msg = [NSString stringWithFormat:@"收藏%@节点成功",self.model.nodeTitle] ;
                [FFToast showToastWithTitle:@"收藏成功" message:msg iconImage:nil duration:2 toastType:FFToastTypeSuccess] ;
            } failure:^(NSError *error) {
                NSString *msg = [NSString stringWithFormat:@"收藏`%@`节失败,请重试",self.model.nodeTitle] ;
                [FFToast showToastWithTitle:@"收藏失败" message:msg iconImage:nil duration:2 toastType:FFToastTypeSuccess] ;
            }];
            
        }
        [self hideMenuAnimated:NO];
    };
    
    for (int i = 0; i < 2; i ++) {
        V2TopicToolBarItemView *item = [[V2TopicToolBarItemView alloc] init];
        item.itemTitle = itemTitleArray[i];
        item.itemImage = [UIImage imageNamed:itemImageArray[i]];
        item.alpha = 1.0;
        item.buttonPressedBlock = ^{
            buttonHandleBlock(i);
        };
        item.frame = (CGRect){0, 44 * i, item.width, item.height};
        item.backgroundColorNormal = [UIColor clearColor];
        [menuBackgroundView addSubview:item];
    }
    
    // Handles
    [self.menuBackgroundButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self hideMenuAnimated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)loadData:(BOOL)isLoadMore{
    if(self.currentTask){
        [self.currentTask cancel] ;
    }
    NSInteger page = 1 ;
    if (isLoadMore) {
        page = ++self.pageCount ;
    }
    @weakify(self);
    self.currentTask = [[V2DataManager manager]getTopicListWithNodeId:nil nodename:self.model.nodeName username:nil page:page success:^(NSArray<V2Topic *> *list) {
        @strongify(self);
        if(isLoadMore){
            NSMutableArray *newList = [self.topicList mutableCopy];
            [newList addObjectsFromArray:[list mutableCopy]] ;
            self.topicList = newList ;
            [self endLoadMore];
        }else{
            self.topicList = [list mutableCopy];
            [self endRefresh];
        }
        
    } failure:^(NSError *error) {
        @strongify(self);
        if (self.pageCount > 1) {
            [self endLoadMore];
        } else {
            [self endRefresh];
        }
    }];
}


#pragma mark - Private Methods

- (void)showMenuAnimated:(BOOL)animated {
    
    if (self.isMenuShowing) {
        return;
    }
    
    self.isMenuShowing = YES;
    
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    CGRect addBarF = [self.menuContainView convertRect:self.addBarItem.view.frame fromView:window];
    self.menuView.frame = (CGRect){CGRectGetMidX(addBarF) - 72, CGRectGetMaxY(addBarF), 130, 118};
    
    if (animated) {
        self.menuView.origin = (CGPoint){CGRectGetMidX(addBarF) - 72, CGRectGetMaxY(addBarF) - 44};
        self.menuView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.menuView.alpha = 1.0;
            self.menuView.transform = CGAffineTransformIdentity;
            self.menuView.frame = (CGRect){CGRectGetMidX(addBarF) - 92, CGRectGetMaxY(addBarF), 130, 118};
        } completion:^(BOOL finished) {
            self.menuContainView.userInteractionEnabled = YES;
        }];
    } else {
        self.menuView.alpha = 1.0;
        self.menuView.transform = CGAffineTransformIdentity;
        self.menuView.frame = (CGRect){CGRectGetMidX(addBarF) - 72, CGRectGetMaxY(addBarF), 130, 118};
        self.menuContainView.userInteractionEnabled = YES;
    }
    
}

- (void)hideMenuAnimated:(BOOL)animated {
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    CGRect addBarF = [self.menuContainView convertRect:self.addBarItem.view.frame fromView:window];
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.menuView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.menuContainView.userInteractionEnabled = NO;
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.menuView.transform = CGAffineTransformMakeScale(0.3, 0.3);
            self.menuView.origin = (CGPoint){CGRectGetMidX(addBarF) - 72 + 40, CGRectGetMaxY(addBarF)};
        } completion:^(BOOL finished) {
            self.menuView.transform = CGAffineTransformIdentity;
            self.menuView.frame = (CGRect){CGRectGetMidX(addBarF) - 72, CGRectGetMaxY(addBarF), 130, 118};
            self.isMenuShowing = NO;
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            self.menuView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.menuContainView.userInteractionEnabled = NO;
            self.isMenuShowing = NO;
        }];
    }
}

#pragma mark --- Set
- (void)setTopicList:(NSMutableArray<V2Topic *> *)topicList{
    if (_topicList.lastObject.topicId == topicList.lastObject.topicId && self.pageCount != 1) {
        [FFToast showToastWithTitle:@"没有更多的数据" message:nil iconImage:nil duration:2 toastType:FFToastTypeWarning] ;
    }else{
        _topicList = topicList;
        [self.tableView reloadData];
    }

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
        if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4) {
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                [self registerForPreviewingWithDelegate:self sourceView:cell];
            }
        }
    }
    return [self configureTopicCellWithCell:cell IndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    V2Topic *model = self.topicList[indexPath.row];
    V2TopicViewController *topicViewController = [[V2TopicViewController alloc] init];
    topicViewController.model = model;
    [self.navigationController pushViewController:topicViewController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark --- setup Cell
- (CGFloat)heightOfTopicCellForIndexPath:(NSIndexPath *)indexPath {
    V2Topic *model = self.topicList[indexPath.row];
    return [V2TopicCell getCellHeightWithTopic:model] + [self.model.nodeName heightForFont:[UIFont systemFontOfSize:12
                                                                                            ] width:MAXFLOAT] + 5;
}

- (V2TopicCell *)configureTopicCellWithCell:(V2TopicCell *)cell IndexPath:(NSIndexPath *)indexPath {
    V2Topic *model = self.topicList[indexPath.row];
    model.topicNode = self.model ;
    model.topicCreatedDescription = @"" ;
    cell.model = model;
    cell.isTop = !indexPath.row;
    return cell;
}

#pragma mark --- Preview
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

- (void)didReceiveTopicCreateSuccessNotification {
    [self beginRefresh] ;
}

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
