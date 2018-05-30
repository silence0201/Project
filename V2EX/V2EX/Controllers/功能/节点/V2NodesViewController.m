//
//  V2NodesViewController.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2NodesViewController.h"
#import "SINavigationController.h"
#import "V2NodesViewCell.h"
#import "V2NodeViewController.h"

@interface V2NodesViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) SIBarButtonItem    *leftBarItem;

@property (nonatomic, strong) NSArray *headerTitleArray;
@property (nonatomic, strong) NSArray *nodesArray;

@property (nonatomic, strong) NSArray *myNodesArray;
@property (nonatomic, strong) NSArray *otherNodesArray;

@property (nonatomic, copy) NSURLSessionDataTask* (^getNodeListBlock)();
@property (nonatomic, copy) NSString *myNodeListPath;
@property (nonatomic, strong) NSURLSessionDataTask *currentTask ;

@end

@implementation V2NodesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBarItems] ;
    [self setupTableViews] ;
    [self setupData] ;
    self.refreshEnabled = NO ;
    @weakify(self);
    self.refreshBlock = ^{
        @strongify(self);
        [self loadData] ;
    };
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLoginSuccessNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self beginRefresh] ;
    }] ;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLogoutSuccessNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self beginRefresh] ;
    }] ;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self] ;
}

- (void)setupData{
    self.headerTitleArray = @[@"我的节点",@"分享与探索", @"V2EX", @"iOS", @"Geek", @"游戏", @"Apple", @"生活", @"Internet", @"城市", @"品牌"];
    
    self.myNodeListPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.myNodeListPath = [self.myNodeListPath stringByAppendingString:@"/nodes.plist"];
    
    self.myNodesArray = [NSArray arrayWithContentsOfFile:self.myNodeListPath];
    if (!self.myNodesArray) {
        self.myNodesArray = [NSArray array];
    }
    self.otherNodesArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NodesList" ofType:@"plist"]];
    
    NSMutableArray *nodesArray = [NSMutableArray arrayWithObject:self.myNodesArray];;
    [nodesArray addObjectsFromArray:self.otherNodesArray];
    
    self.nodesArray = [self itemsWithDictArray:nodesArray];
    [self.tableView reloadData] ;
}

- (void)setupBarItems{
    self.leftBarItem = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_menu_2"] handler:^(id sender) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
    }];
    
    self.naviItem.title = @"节点";
    self.naviItem.leftBarButtonItem = self.leftBarItem;
}

- (void)setupTableViews{
    self.tableView                 = [[SIEmptyTableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 15, 0) ;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated] ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self beginRefresh] ;
    });
}

- (void)loadData{
    if (self.currentTask) {
        [self.currentTask cancel] ;
    }
    @weakify(self);
    self.currentTask = [[V2DataManager manager] getMemberNodeListSuccess:^(NSArray *list) {
        @strongify(self);
        [list writeToFile:self.myNodeListPath atomically:NO] ;
        self.myNodesArray = list ;
        NSMutableArray *nodesArray = [NSMutableArray arrayWithObject:self.myNodesArray];
        [nodesArray addObjectsFromArray:self.otherNodesArray];
        self.nodesArray = [self itemsWithDictArray:nodesArray];
        [self.tableView reloadData] ;
        [self endRefresh];
    } failure:^(NSError *error) {
        @strongify(self);
        [self endRefresh];
    }] ;
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headerTitleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [V2NodesViewCell getCellHeightWithNodesArray:self.nodesArray[indexPath.section]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *nodeCellIdentifier = @"nodeCellIdentifier";
    V2NodesViewCell *nodeCell = (V2NodesViewCell *)[tableView dequeueReusableCellWithIdentifier:nodeCellIdentifier];
    if (!nodeCell) {
        nodeCell = [[V2NodesViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nodeCellIdentifier];
    }
    nodeCell.navi = self.navigationController;
    nodeCell.nodesArray = self.nodesArray[indexPath.section];
    return nodeCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 36}];
    headerView.backgroundColor = kBackgroundColorWhiteDark;
    
    UILabel *label                       = [[UILabel alloc] initWithFrame:(CGRect){10, 0, kScreenWidth - 20, 36}];
    label.textColor                      = kFontColorBlackLight;
    label.font                           = [UIFont systemFontOfSize:15.0];
    label.text                           = self.headerTitleArray[section];
    [headerView addSubview:label];
    
    if (section == 0) {
        UIView *topBorderLineView            = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0.5}];
        topBorderLineView.backgroundColor    = kLineColorBlackDark;
        [headerView addSubview:topBorderLineView];
    }
    
    UIView *bottomBorderLineView         = [[UIView alloc] initWithFrame:(CGRect){0, 35.5, kScreenWidth, 0.5}];
    bottomBorderLineView.backgroundColor = kLineColorBlackDark;
    [headerView addSubview:bottomBorderLineView];
    
    return headerView;
}

// 根据名字获取节点信息
- (NSArray *)itemsWithDictArray:(NSArray *)nodesArray {
    NSMutableArray *items = [NSMutableArray new];
    for (NSArray *sectionDictList in nodesArray) {
        NSMutableArray *setionItems = [NSMutableArray new];
        for (NSDictionary *dataDict in sectionDictList) {
            NSString *nodeTitle = dataDict[@"name"];
            NSString *nodeName = dataDict[@"title"];
            V2Node *model = [[V2Node alloc] init];
            model.nodeTitle = nodeTitle;
            model.nodeName = nodeName;
            [setionItems addObject:model];
        }
        [items addObject:setionItems];
    }
    return items;
}
@end
