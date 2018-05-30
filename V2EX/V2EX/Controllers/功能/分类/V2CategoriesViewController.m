//
//  V2CategoriesViewController.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2CategoriesViewController.h"
#import "V2TopicViewController.h"
#import "V2CategoriesMenuView.h"
#import "SINavigationController.h"
#import "V2LoginViewController.h"
#import "V2TopicCell.h"

#define keyFromCategoriesType(type) [NSString stringWithFormat:@"categoriesKey%zd", type]
#define keyFromFavoriteType(type) [NSString stringWithFormat:@"categoriesKey%zd", type]

@interface V2CategoriesViewController ()<UITableViewDelegate,UITableViewDataSource,UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) V2CategoriesMenuView             *sectionView;
@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePanRecognizer;
@property (nonatomic, strong) UIImageView                      *leftShadowImageView;
@property (nonatomic, strong) UIView                           *leftShdowImageMaskView;

@property (nonatomic, strong) UIButton                         *aboveTableViewButton;

@property (nonatomic, strong) SIBarButtonItem                  *leftBarItem;
@property (nonatomic, strong) SIBarButtonItem                  *rightBarItemDefault;
@property (nonatomic, strong) SIBarButtonItem                  *rightBarItemExpend;


@property (nonatomic, strong) NSMutableDictionary              *topicListDict;

@property (nonatomic, assign) V2HotNodesType categoriesType;
@property (nonatomic, assign) V2HotNodesType favoriteType;

@property (nonatomic, strong) NSURLSessionDataTask *currentTask;
@property (nonatomic, assign) NSInteger currentPage;



@end

@implementation V2CategoriesViewController

#pragma mark --- init
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        _topicListDict = [NSMutableDictionary dictionary] ;
        _favorite = NO ;
    }
    return self ;
}

- (void)setupSectionView{
    self.sectionView = [[V2CategoriesMenuView alloc] initWithFrame:(CGRect){kScreenWidth - 20, 0, 120, self.view.height}];
    if (self.isFavorite) {
        self.sectionView.favorite = YES;
        self.sectionView.sectionTitleArray = @[@"节点收藏", @"特别关注", @"主题收藏"] ;
    } else {
        self.sectionView.favorite = NO;
        self.sectionView.sectionTitleArray = @[@"技术", @"创意", @"好玩", @"Apple", @"酷工作", @"交易", @"城市", @"问与答", @"最热", @"全部", @"R2"];
    }
    
    [self.view addSubview:self.sectionView];
    
    @weakify(self);
    [self.sectionView setSelectedAction:^(NSInteger index) {
        @strongify(self);
        if (self.isFavorite) {
            [V2SettingManager manager].favoriteSelectedSectionIndex = index;
        } else {
            [V2SettingManager manager].categoriesSelectedSectionIndex = index;
        }
        self.naviItem.title = self.sectionView.sectionTitleArray[index];
        [UIView animateWithDuration:0.3 animations:^{
            [self setMenuOffset:0.0];
        } completion:^(BOOL finished) {
            self.aboveTableViewButton.hidden = YES;
            NSMutableArray<V2Topic *> *storedList ;
            if (self.isFavorite) {
                storedList = [self.topicListDict objectForKey:keyFromFavoriteType(self.favoriteType)];
            } else {
                storedList = [self.topicListDict objectForKey:keyFromCategoriesType(self.categoriesType)];
            }
            if (storedList) {
                self.topicList = storedList;
            } else {
                self.topicList = nil;
                [self setNavigationBarHidden:NO animated:YES] ;
            }
            [self beginRefresh];
            [self.tableView scrollRectToVisible:(CGRect){0, 0, 1, 1} animated:YES];
        }];
        
    }];

}

- (void)setupTableView{
    self.tableView                 = [[SIEmptyTableView alloc] initWithFrame:self.view.frame];
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    UIEdgeInsets newContentInset   = self.tableView.contentInset;
    newContentInset.top            = 64;
    self.tableView.contentInset    = newContentInset;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    [self.view addSubview:self.tableView];
    
    self.aboveTableViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.aboveTableViewButton.hidden = YES;
    [self.view addSubview:self.aboveTableViewButton];
    
    // Handles
    [self.aboveTableViewButton bk_addEventHandler:^(id sender) {
        [UIView animateWithDuration:0.3 animations:^{
            [self setMenuOffset:0];
        } completion:^(BOOL finished) {
            UIButton *button = (UIButton *)sender;
            button.hidden = YES;
        }];
    } forControlEvents:UIControlEventTouchUpInside];

}

- (void)setupShadowViews{
    self.leftShdowImageMaskView               = [[UIView alloc] init];
    self.leftShdowImageMaskView.clipsToBounds = YES;
    [self.view addSubview:self.leftShdowImageMaskView];
    
    UIImage *shadowImage               = [UIImage imageNamed:@"Navi_Shadow"];
    self.leftShadowImageView           = [[UIImageView alloc] initWithImage:shadowImage];
    self.leftShadowImageView.transform = CGAffineTransformMakeRotation(M_PI);
    self.leftShadowImageView.alpha     = 0.0;
    [self.leftShdowImageMaskView addSubview:self.leftShadowImageView];
}

- (void)setupNavBarItems{
    self.leftBarItem = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_menu_2"] handler:^(id sender) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
    }];
    self.rightBarItemExpend = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_dot"] handler:^(id sender) {
        if (self.aboveTableViewButton.hidden) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self setMenuOffset: - self.sectionView.width];
                self.aboveTableViewButton.hidden = NO;
            } completion:nil];
        }else {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self setMenuOffset:0];
                self.aboveTableViewButton.hidden = YES;
            } completion:nil];
        }
    }];
}

#pragma mark - Layouts

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.hiddenEnabled = YES;
    self.leftShdowImageMaskView.frame = (CGRect){self.tableView.width, 0, 10, kScreenHeight};
    self.leftShadowImageView.frame    = (CGRect){-10, 0, 10, kScreenHeight};
    self.aboveTableViewButton.frame   = self.tableView.frame;
}

- (void)setupGestures{
    self.edgePanRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UIScreenEdgePanGestureRecognizer *recognizer = (UIScreenEdgePanGestureRecognizer *)sender;
        CGFloat progress = -[recognizer translationInView:self.view].x / (self.view.bounds.size.width * 0.5) ;
        progress = MIN(1.0,MAX(0.0, progress)) ;
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            if (self.aboveTableViewButton.hidden) {
                [self setMenuOffset: - self.sectionView.width * progress] ;
            }
        }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled){
            CGFloat velocity = [recognizer velocityInView:self.view].x;
            if (velocity < -10 || progress > 0.5) {
                [UIView animateWithDuration:0.3 animations:^{
                    [self setMenuOffset: - self.sectionView.width];
                    self.aboveTableViewButton.hidden = NO;
                } completion:nil];
            }else {
                [UIView animateWithDuration:0.3 animations:^{
                    [self setMenuOffset:0];
                    self.aboveTableViewButton.hidden = YES;
                } completion:nil];
            }
        }
    }] ;
    self.edgePanRecognizer.edges = UIRectEdgeRight ;
    [self.view addGestureRecognizer:self.edgePanRecognizer] ;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;
        if (self.aboveTableViewButton.hidden) {
            return ;
        }
        CGFloat progress = [recognizer translationInView:self.view].x / (self.view.bounds.size.width * 0.5);
        progress = MIN(1.0, MAX(0.0, progress));
        if (recognizer.state == UIGestureRecognizerStateChanged) {
            [self setMenuOffset: - self.sectionView.width * (1 - progress)];
        }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
            CGFloat velocity = [recognizer velocityInView:self.view].x;
            if (velocity < -10 || progress > 0.5) {
                [UIView animateWithDuration:0.3 animations:^{
                    [self setMenuOffset:0];
                    self.aboveTableViewButton.hidden = YES;
                } completion:nil];
            }else {
                [UIView animateWithDuration:0.3 animations:^{
                    [self setMenuOffset: - self.sectionView.width];
                    self.aboveTableViewButton.hidden = NO;
                } completion:nil];
            }
        }
    }];
    [self.aboveTableViewButton addGestureRecognizer:panRecognizer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSectionView] ;
    [self setupTableView] ;
    [self setupShadowViews] ;
    [self setupNavBarItems] ;
    [self setupGestures] ;
    self.naviItem.leftBarButtonItem = self.leftBarItem;
    self.naviItem.rightBarButtonItem = self.rightBarItemExpend;
    self.currentPage = 1 ;
    
    @weakify(self);
    self.refreshBlock = ^{
        @strongify(self);
        if (self.isFavorite) {
            [self loadDataWithType:self.favoriteType loadMore:NO] ;
        } else {
            [self loadDataWithType:self.categoriesType loadMore:NO] ;
        }
    };
    
    if (self.isFavorite) {
        self.loadMoreBlock = ^{
            @strongify(self);
            [self loadDataWithType:self.favoriteType loadMore:YES] ;
        };
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveIgnoreTopicSuccessNotification:) name:kIgnoreTopicSuccessNotification object:nil];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated] ;
    
    if(self.isFavorite){
        if(![V2UserManager manager].user && self.needLogin){
            self.tableView.title = @"查看收藏信息需要登录" ;
            self.tableView.buttonTitle = @"登录" ;
            @weakify(self);
            self.tableView.emptyClickAction = ^(){
                @strongify(self) ;
                [self presentViewController:[V2LoginViewController new] animated:YES completion:nil] ;
            } ;
        }else{
            self.naviItem.title = self.sectionView.sectionTitleArray[[V2SettingManager manager].favoriteSelectedSectionIndex];
            @weakify(self);
            self.tableView.emptyClickAction = ^(){
                @strongify(self) ;
                [self beginRefresh];
            } ;
        }
    }else{
        self.naviItem.title = self.sectionView.sectionTitleArray[[V2SettingManager manager].categoriesSelectedSectionIndex];
    }

}

- (void)loadDataWithType:(V2HotNodesType)type loadMore:(BOOL)isLoadMore{
    if(self.currentTask){
        [self.currentTask cancel] ;
    }
    
    if(self.isFavorite && self.favoriteType != V2HotNodesTypeNodes){
        // 初始为1
        NSInteger page = 1 ;
        if (isLoadMore) {
            page = ++self.currentPage ;
        }
        self.currentPage = page ;
        @weakify(self);
        self.currentTask = [[V2DataManager manager] getMemberTopicListWithType:self.favoriteType page:page Success:^(NSArray<V2Topic *> *list) {
            @strongify(self);
            if (isLoadMore) {
                NSMutableArray *newList = [self.topicList mutableCopy];
                [newList addObjectsFromArray:[list mutableCopy]] ;
                self.topicList = newList ;
            } else {
                self.topicList = [list mutableCopy] ;
            }
            [self.topicListDict setObject:list forKey:keyFromFavoriteType(type)];
            if (isLoadMore) {
                [self endLoadMore];
            } else {
                [self endRefresh];
            }
        } failure:^(NSError *error) {
            @strongify(self);
            if (isLoadMore) {
                [self endLoadMore];
            } else {
                [self endRefresh];
            }
        }] ;
    }else{
        if (self.isFavorite) {
            type = V2HotNodesTypeNodes;
        } else {
            type = self.categoriesType;
        }
        @weakify(self);
        self.currentTask = [[V2DataManager manager] getTopicListWithType:type Success:^(NSArray<V2Topic *> *list) {
            @strongify(self);
            self.topicList = [list mutableCopy] ;
            [self.topicListDict setObject:list forKey:keyFromCategoriesType(type)];
            if (isLoadMore) {
                [self endLoadMore];
            } else {
                [self endRefresh];
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
}

- (void)setTopicList:(NSMutableArray<V2Topic *> *)topicList {
    if (_topicList.lastObject.topicId == topicList.lastObject.topicId && self.currentPage != 1) {
        [FFToast showToastWithTitle:@"没有更多的数据" message:nil iconImage:nil duration:2 toastType:FFToastTypeWarning] ;
    }else{
        _topicList = topicList ;
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
}

#pragma mark - Configure TableCell

- (CGFloat)heightOfTopicCellForIndexPath:(NSIndexPath *)indexPath {
    V2Topic *model = self.topicList[indexPath.row];
    return [V2TopicCell getCellHeightWithTopic:model];
}

- (V2TopicCell *)configureTopicCellWithCell:(V2TopicCell *)cell IndexPath:(NSIndexPath *)indexPath {
    V2Topic *model = self.topicList[indexPath.row];
    cell.model = model;
    cell.isTop = !indexPath.row;
    return cell;
}

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

#pragma mark - Private Methods

- (void)setMenuOffset:(CGFloat)offset {
    self.tableView.left               = offset;
    self.aboveTableViewButton.left    = offset;
    self.leftShdowImageMaskView.left  = kScreenWidth + offset;
    self.leftShadowImageView.left     = (MIN((-offset / 110), 1.0)) * 10 - 10;
    self.leftShadowImageView.alpha    = MIN((-offset / 200), 0.3);
    self.sectionView.left             = kScreenWidth - 20 + (offset / self.sectionView.width) * (self.sectionView.width - 20);
}

- (V2HotNodesType)categoriesType {
    
    V2HotNodesType type = V2HotNodesTypeHot;
    
    switch ([V2SettingManager manager].categoriesSelectedSectionIndex) {
        case 0:
            type = V2HotNodesTypeTech;
            break;
        case 1:
            type = V2HotNodesTypeCreative;
            break;
        case 2:
            type = V2HotNodesTypePlay;
            break;
        case 3:
            type = V2HotNodesTypeApple;
            break;
        case 4:
            type = V2HotNodesTypeJobs;
            break;
        case 5:
            type = V2HotNodesTypeDeals;
            break;
        case 6:
            type = V2HotNodesTypeCity;
            break;
        case 7:
            type = V2HotNodesTypeQna;
            break;
        case 8:
            type = V2HotNodesTypeHot;
            break;
        case 9:
            type = V2HotNodesTypeAll;
            break;
        case 10:
            type = V2HotNodesTypeR2;
            break;
        default:
            type = V2HotNodesTypeAll;
            break;
    }
    
    return type;
}

- (V2HotNodesType)favoriteType {
    V2HotNodesType type = V2HotNodesTypeNodes;
    switch ([V2SettingManager manager].favoriteSelectedSectionIndex) {
        case 0:
            type = V2HotNodesTypeNodes ;
        case 1:
            type = V2HotNodesTypeMembers;
            break;
        case 2:
            type = V2HotNodesTypeFav;
            break;
        default:
            break;
    }
    return type;
}

- (BOOL)canRefresh{
    if (self.isNeedLogin && [V2UserManager manager].user == nil) {
        return NO ;
    }
    return YES ;
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
