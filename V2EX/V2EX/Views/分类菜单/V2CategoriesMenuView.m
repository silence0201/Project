//
//  V2CategoriesMenuView.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/21.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2CategoriesMenuView.h"
#import "V2CategoriesMenuCell.h"

static NSString *CellIdentifier = @"V2Cate" ;

@interface V2CategoriesMenuView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView ;

@end

@implementation V2CategoriesMenuView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self setupTableView] ;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
    }
    return self ;
}

- (void)setupTableView{
    self.tableView = [[UITableView alloc]init] ;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
    self.tableView.delegate = self ;
    self.tableView.dataSource = self ;
    self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0) ;
    [self.tableView registerClass:[V2CategoriesMenuCell class] forCellReuseIdentifier:CellIdentifier] ;
    [self addSubview:self.tableView] ;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark --- Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = (CGRect){0, 0, self.width, self.height};
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    
    NSUInteger row = 0;
    if (self.isFavorite) {
        row = [V2SettingManager manager].favoriteSelectedSectionIndex;
    } else {
        row = [V2SettingManager manager].categoriesSelectedSectionIndex;
    }
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark --- Data
- (void)setSectionTitleArray:(NSArray *)sectionTitleArray {
    _sectionTitleArray = sectionTitleArray;
    [self.tableView reloadData];
}

#pragma mark --- TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.sectionTitleArray.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    V2CategoriesMenuCell *cell = (V2CategoriesMenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath] ;
    return  [self setupCell:cell index:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [V2CategoriesMenuCell getCellHeight] ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.selectedAction){
        self.selectedAction(indexPath.row) ;
    }
}

#pragma mark --- setup Cell
- (V2CategoriesMenuCell *)setupCell:(V2CategoriesMenuCell *)cell index:(NSIndexPath *)indexPath{
    cell.title = self.sectionTitleArray[indexPath.row] ;
    return cell ;
}

#pragma mark - Notifications
- (void)didReceiveThemeChangeNotification {
    [self.tableView reloadData];
    [self setNeedsLayout];
}



@end
