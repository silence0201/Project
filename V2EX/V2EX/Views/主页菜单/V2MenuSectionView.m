//
//  V2MenuSectionView.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2MenuSectionView.h"
#import "SIActionSheet.h"
#import "V2MenuSectionCell.h"


static CGFloat const kAvatarHeight = 70.0f;

@interface V2MenuSectionView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIImageView   *avatarImageView;
@property (nonatomic, strong) UIButton      *avatarButton;
@property (nonatomic, strong) UIImageView   *divideImageView;
@property (nonatomic, strong) UILabel       *usernameLabel;

@property (nonatomic, strong) SIActionSheet *actionSheet;

@property (nonatomic, strong) UITableView   *tableView;

@property (nonatomic, strong) NSArray       *sectionImageNameArray;
@property (nonatomic, strong) NSArray       *sectionTitleArray;

@end

@implementation V2MenuSectionView

#pragma mark --- init
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.sectionImageNameArray = @[@"section_latest", @"section_categories", @"section_nodes", @"section_fav", @"section_notification", @"section_profile"] ;
        self.sectionTitleArray = @[@"最新", @"分类", @"节点", @"收藏", @"提醒", @"个人"];
        
        [self setupTableView] ;
        [self setupProfileView] ;
        [self setupNotifications] ;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
    }
    return self ;
}

- (void)setupTableView{
    self.tableView                 = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    UIEdgeInsets newContentInset = self.tableView.contentInset;
    newContentInset.top = 120;
    self.tableView.contentInset = newContentInset;
    [self addSubview:self.tableView];
}

- (void)setupProfileView{
    self.avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar_default"]];
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 5;
    self.avatarImageView.layer.borderColor = RGB(0x8a8a8a, 1.0).CGColor;
    self.avatarImageView.layer.borderWidth = 1.0f;
    [self addSubview:self.avatarImageView] ;
    
    self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
    
    if ([V2UserManager manager].user.isLogin) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[V2UserManager manager].user.member.memberAvatarLarge] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        self.avatarImageView.layer.borderColor = RGB(0x8a8a8a, 0.1).CGColor;
    }
    
    self.avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.avatarButton];
    
    self.divideImageView = [[UIImageView alloc] init];
    self.divideImageView.backgroundColor = kLineColorBlackDark;
    self.divideImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.divideImageView.clipsToBounds = YES;
    [self addSubview:self.divideImageView];
    
    // Handles
    [self.avatarButton bk_addEventHandler:^(id sender) {
        if (![V2UserManager manager].user.isLogin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginVCNotification object:nil];
        } else {
            self.actionSheet = [[SIActionSheet alloc] initWithTitles:@[@"是否注销？"] customViews:nil buttonTitles:@"注销", nil];
            [self.actionSheet configureButtonWithBlock:^(SIActionSheetButton *button) {
                button.type = SIActionSheetButtonTypeRed;
            } forIndex:0];
            [self.actionSheet setButtonHandler:^{
                [[V2UserManager manager] UserLogout];
            } forIndex:0];
            [self.actionSheet show:YES];
        }
        
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupNotifications{
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:kLoginSuccessNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[V2UserManager manager].user.member.memberAvatarLarge] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        self.avatarImageView.layer.borderColor = RGB(0x8a8a8a, 0.1).CGColor;
        
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLogoutSuccessNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[V2UserManager manager].user.member.memberAvatarLarge] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        self.avatarImageView.layer.borderColor = RGB(0x8a8a8a, 1.0).CGColor;
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark --- Layout
- (void)layoutSubviews {
    self.avatarImageView.frame = (CGRect){30, 30, kAvatarHeight, kAvatarHeight};
    self.avatarButton.frame = self.avatarImageView.frame;
    self.divideImageView.frame = (CGRect){-self.width, kAvatarHeight + 50, self.width * 2, 0.5};
    self.tableView.frame = (CGRect){0, 0, self.width, self.height};
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[V2SettingManager manager].selectedSectionIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Setters

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex < self.sectionTitleArray.count) {
        _selectedIndex = selectedIndex;
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - TableViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = - scrollView.contentOffset.y;
    self.avatarImageView.top = 30 - (scrollView.contentInset.top - offsetY) / 1.7;
    self.avatarButton.frame = self.avatarImageView.frame;
    self.divideImageView.top = self.avatarImageView.top + kAvatarHeight + (offsetY - (self.avatarImageView.top + kAvatarHeight)) / 2.0 + fabs(offsetY - self.tableView.contentInset.top)/self.tableView.contentInset.top * 8.0 + 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sectionTitleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightCellForIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelectedIndexBlock) {
        self.didSelectedIndexBlock(indexPath.row);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    V2MenuSectionCell *cell = (V2MenuSectionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[V2MenuSectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return [self setupCell:cell IndexPath:indexPath] ;
}

#pragma mark - setup TableCell
- (CGFloat)heightCellForIndexPath:(NSIndexPath *)indexPath {
    return [V2MenuSectionCell getCellHeight];
}

- (V2MenuSectionCell *)setupCell:(V2MenuSectionCell *)cell IndexPath:(NSIndexPath *)indexPath{
    cell.imageName = self.sectionImageNameArray[indexPath.row];
    cell.title     = self.sectionTitleArray[indexPath.row];
    cell.badge = nil;
    return cell;
}

#pragma mark - Notifications
- (void)didReceiveThemeChangeNotification {
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[V2SettingManager manager].selectedSectionIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
    self.divideImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
}


@end
