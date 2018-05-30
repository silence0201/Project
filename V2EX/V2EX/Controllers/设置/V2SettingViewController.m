//
//  V2SettingViewController.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2SettingViewController.h"

#import "V2SettingCell.h"
#import "V2SettingCheckInCell.h"
#import "V2SettingSwitchCell.h"

#import "SIActionSheet.h"
#import "SINavigationController.h"

#import "V2WebViewController.h"

typedef NS_ENUM(NSInteger, V2SettingSection) {
    V2SettingSectionDisplay      = 0,
    V2SettingSectionTraffic      = 1,
    V2SettingSectionCheckIn      = 2,
    V2SettingSectionAbout        = 3,
};


@interface V2SettingViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *headerTitleArray;

@property (nonatomic, strong) SIBarButtonItem *backBarItem;

@property (nonatomic, strong) SIActionSheet *actionSheet;


@end

@implementation V2SettingViewController


- (void)setupBarItems{
    self.backBarItem = [self createBackItem] ;
    self.naviItem.leftBarButtonItem = self.backBarItem ;
    self.naviItem.title = @"设置" ;
}

- (void)setupTableView{
    self.tableView                 = [[SIEmptyTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableViewInsertTop = 20 ;
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    [self setupBarItems] ;
    [self setupTableView] ;
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated] ;
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 15, 0) ;
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == V2SettingSectionDisplay) {
        return 3 ;
    }
    if (section == V2SettingSectionAbout) {
        return 2 ;
    }
    return  1 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *checkInCellIdentifier = @"CheckInSettingIdentifier";
    V2SettingCheckInCell *checkInCell = (V2SettingCheckInCell *)[tableView dequeueReusableCellWithIdentifier:checkInCellIdentifier];
    if (!checkInCell) {
        checkInCell = [[V2SettingCheckInCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:checkInCellIdentifier];
    }
    
    static NSString *switchCellIdentifier = @"SwitchSettingIdentifier";
    V2SettingSwitchCell *switchCell = (V2SettingSwitchCell *)[tableView dequeueReusableCellWithIdentifier:switchCellIdentifier];
    if (!switchCell) {
        switchCell = [[V2SettingSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:switchCellIdentifier];
    }
    
    static NSString *CellIdentifier = @"SettingIdentifier";
    V2SettingCell *settingCell = (V2SettingSwitchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!settingCell) {
        settingCell = [[V2SettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == V2SettingSectionDisplay) {
        if (indexPath.row == 0) {
            switchCell.title = @"夜间模式";
            switchCell.isOn = kSetting.theme == V2ThemeNight;
            switchCell.top = YES;
        }
        if (indexPath.row == 1) {
            switchCell.title = @"自动选择夜间模式";
            switchCell.isOn = kSetting.themeAutoChange;
        }
        if (indexPath.row == 2) {
            switchCell.title = @"自动隐藏导航栏";
            switchCell.isOn = kSetting.navigationBarAutoHidden;
            switchCell.bottom = YES;
        }
        return switchCell;
    }
    
    if (indexPath.section == V2SettingSectionTraffic) {
        if (indexPath.row == 0) {
            switchCell.title = @"省流量模式";
            switchCell.isOn = kSetting.trafficSaveModeOnSetting;
            switchCell.top = YES;
            switchCell.bottom = YES;
        }
        return switchCell;
    }
    
    if (indexPath.section == V2SettingSectionCheckIn) {
        checkInCell.title = @"签到";
        checkInCell.top = YES;
        checkInCell.bottom = YES;
        return checkInCell;
    }
    
    if (indexPath.section == V2SettingSectionAbout) {
        if (indexPath.row == 0) {
            settingCell.title = @"关于作者";
            settingCell.top = YES;
        }
        if (indexPath.row == 1) {
            settingCell.title = @"关于V2EX";
            settingCell.bottom = YES;
        }
        return settingCell;
    }
    UITableViewCell *blackCell = [UITableViewCell new];
    blackCell.backgroundColor = kBackgroundColorWhite;
    return blackCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    V2SettingCell *settingCell = (V2SettingCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if ([settingCell isKindOfClass:[V2SettingSwitchCell class]]) {
        V2SettingSwitchCell *switchCell = (V2SettingSwitchCell *)settingCell;
        switchCell.isOn = !switchCell.isOn;
        if (indexPath.section == V2SettingSectionDisplay) {
            if (indexPath.row == 0) {
                if (switchCell.isOn) {
                    kSetting.theme = V2ThemeNight;
                } else {
                    kSetting.theme = V2ThemeDefault;
                }
            }
            if (indexPath.row == 1) {
                kSetting.themeAutoChange = switchCell.isOn;
            }
            if (indexPath.row == 2) {
                kSetting.navigationBarAutoHidden = switchCell.isOn;
            }
        }
        if (indexPath.section == V2SettingSectionTraffic) {
            kSetting.trafficSaveModeOn = switchCell.isOn;
        }
    }
    
    if ([settingCell isKindOfClass:[V2SettingCheckInCell class]]) {
        V2SettingCheckInCell *checkInCell = (V2SettingCheckInCell *)settingCell;
        if ([V2CheckInManager manager].isExpired) {
            [checkInCell beginCheckIn];
            [[V2CheckInManager manager] checkInSuccess:^(NSInteger count) {
                [checkInCell endCheckIn];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } failure:^(NSError *error) {
                [checkInCell endCheckIn];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
        }
    }
    
    if (indexPath.section == V2SettingSectionAbout) {
        NSString *url;
        if (indexPath.row == 0) {
            url = @"https://github.com/silence0201" ;
        }
        if (indexPath.row == 1) {
            url = @"https://v2ex.com/about" ;
        }
        V2WebViewController *webVC = [[V2WebViewController alloc] init];
        webVC.url = url;
        [self.navigationController pushViewController:webVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView;
    if (section == V2SettingSectionTraffic) {
        footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 22}];
        footerView.backgroundColor = kBackgroundColorWhiteDark;
        UILabel *label                       = [[UILabel alloc] initWithFrame:(CGRect){15, 0, kScreenWidth - 20, 30}];
        label.textColor                      = kFontColorBlackLight;
        label.font                           = [UIFont systemFontOfSize:12.0];
        label.text = @"移动网络下，不直接显示帖子图片";
        label.alpha = 0.7;
        [label sizeToFit];
        label.top = 15;
        label.top = 22 - label.height;
        [footerView addSubview:label];
    }
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

@end
