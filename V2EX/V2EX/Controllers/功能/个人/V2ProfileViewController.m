//
//  V2ProfileViewController.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2ProfileViewController.h"
#import "V2RootViewController.h"

#import "V2LoginViewController.h"
#import "V2MemberTopicsViewController.h"
#import "V2SettingViewController.h"
#import "V2MemberRepliesViewController.h"
#import "V2WebViewController.h"

#import "SIActionSheet.h"
#import "SINavigationController.h"

#import "V2ProfileCell.h"
#import "V2ProfileBioCell.h"

static CGFloat const kAvatarHeight = 60.0f;
@interface V2ProfileViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) SIBarButtonItem    *leftBarItem;
@property (nonatomic, strong) SIBarButtonItem    *backBarItem;
@property (nonatomic, strong) SIBarButtonItem    *settingBarItem;
@property (nonatomic, strong) SIBarButtonItem    *actionBarItem;

@property (nonatomic, strong) SIActionSheet      *actionSheet;

@property (nonatomic, strong) UIView      *topPanel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UILabel     *signLabel;

@property (nonatomic, strong) NSArray *headerTitleArray;
@property (nonatomic, strong) NSArray *profileCellArray;

@property (nonatomic, strong) NSURLSessionDataTask *currentTask;
@property (nonatomic, assign) BOOL didGetProfile;

@end

@implementation V2ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.headerTitleArray = @[@"社区", @"信息", @"个人简介"];
        self.didGetProfile = NO;
        self.isSelf = YES ;
    }
    return self;
}

- (void)setupBarItems{
    @weakify(self);
    if (self.isSelf) {
        self.leftBarItem = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_menu_2"] handler:^(id sender) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
        }];
        self.settingBarItem = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"section_setting"] handler:^(id sender) {
            @strongify(self);
            V2SettingViewController *settingVC = [[V2SettingViewController alloc] init];
            [self.navigationController pushViewController:settingVC animated:YES];
        }];
    } else {
        self.backBarItem = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] handler:^(id sender) {
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        }];
        self.actionBarItem = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_more"]  handler:^(id sender) {
            @strongify(self);
            self.actionSheet = [[SIActionSheet alloc] initWithTitles:@[self.username] customViews:nil buttonTitles:@"关注", @"屏蔽", nil];
            @weakify(self);
            [self.actionSheet setButtonHandler:^{
                @strongify(self);
                [self memberFollow];
            } forIndex:0];
            [self.actionSheet setButtonHandler:^{
                @strongify(self);
                [self memberBlock];
            } forIndex:1];
            [self.actionSheet show:YES];
        }];
    }
    
    if (self.isSelf) {
        self.naviItem.title = @"个人";
        self.naviItem.leftBarButtonItem = self.leftBarItem;
        self.naviItem.rightBarButtonItem = self.settingBarItem;
    } else {
        self.naviItem.title = @"用户";
        self.naviItem.leftBarButtonItem = self.backBarItem;
        self.naviItem.rightBarButtonItem = self.actionBarItem;
    }
}

- (void)setupTabelView{
    self.tableView = [[SIEmptyTableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped] ;
    self.tableView.backgroundColor = [UIColor clearColor] ;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone ;
    self.tableView.contentInset = UIEdgeInsetsMake(124, 0, 0, 0) ;
    self.tableViewInsertTop = 94;
    self.tableView.delegate = self ;
    self.tableView.dataSource = self ;
    [self.view addSubview:self.tableView] ;
}

- (void)setupTopView{
    self.topPanel = [[UIView alloc] init];
    [self.view addSubview:self.topPanel];
    
    self.avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar_default"]];
    self.avatarImageView.contentMode        = UIViewContentModeScaleAspectFill;
    self.avatarImageView.clipsToBounds      = YES;
    self.avatarImageView.layer.cornerRadius = 5; 
    [self.topPanel addSubview:self.avatarImageView];
    
    self.nameLabel                          = [[UILabel alloc] init];
    self.nameLabel.textColor                = kFontColorBlackDark;
    self.nameLabel.font                     = [UIFont systemFontOfSize:17];;
    [self.topPanel addSubview:self.nameLabel];
    
    self.signLabel                          = [[UILabel alloc] init];
    self.signLabel.textColor                = kFontColorBlackLight;
    self.signLabel.font                     = [UIFont systemFontOfSize:14];
    self.signLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.signLabel.numberOfLines = 2;
    [self.topPanel addSubview:self.signLabel];
    
    // layout
    self.avatarImageView.frame = (CGRect){10, 10, kAvatarHeight, kAvatarHeight};
    self.nameLabel.frame = (CGRect){80, 20, 200, 20};
    self.signLabel.frame = (CGRect){80, 43, 200, 40};
    
    if (self.member) {
        if (self.isSelf) {
            [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.member.memberAvatarLarge] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        } else {
            [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.member.memberAvatarNormal] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        }
        self.nameLabel.text = self.member.memberName;
        self.signLabel.text = self.member.memberTagline;
        [self.signLabel sizeToFit];
        
        self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
    }

}

- (void)setupNotifications{
    if (self.isSelf) {
        @weakify(self);
        [[NSNotificationCenter defaultCenter] addObserverForName:kLoginSuccessNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            @strongify(self);
            self.member = [V2UserManager manager].user.member ;
            [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:self.member.memberAvatarLarge] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
            self.nameLabel.text = self.member.memberName;
            self.signLabel.text = self.member.memberTagline;
            
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate ;
            V2RootViewController *root= app.rootViewController ;
            [root showViewControllerAtIndex:V2SectionIndexProfile animated:YES] ;
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:kLogoutSuccessNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            @strongify(self);
            self.member = [V2UserManager manager].user.member ;
            [self.avatarImageView setImage:[UIImage imageNamed:@"avatar_default"]] ;
            self.nameLabel.text = @"";
            self.signLabel.text = @"";
            
            AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate ;
            V2RootViewController *root= app.rootViewController ;
            [root showViewControllerAtIndex:V2SectionIndexCategories animated:YES] ;
        }] ;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSubViewReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadData{
    if (self.currentTask) {
        [self.currentTask cancel] ;
    }
    
    @weakify(self);
    self.currentTask = [[V2DataManager manager] getMemberProfileWithUserId:nil username:self.username success:^(V2Member *member) {
        @strongify(self);
        self.didGetProfile = YES ;
        self.member = member ;
        self.loadMoreBlock = nil ;
    } failure:^(NSError *error) {
    }] ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBarItems] ;
    [self setupTabelView] ;
    [self setupTopView] ;
    [self setupNotifications] ;
    [self loadData] ;
}

#pragma mark - Layout
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.topPanel.frame = (CGRect){0, 64, kAvatarHeight + 10, kAvatarHeight + 10};
}

#pragma mark --- Action

// 关注
- (void)memberFollow{
    @weakify(self);
    [[V2DataManager manager] memberFollowWithMemberName:self.member.memberName success:^(NSString *message) {
        @strongify(self);
        NSString *msg = [NSString stringWithFormat:@"关注用户%@成功",self.member.memberName] ;
        [FFToast showToastWithTitle:@"关注成功" message:msg iconImage:nil duration:2 toastType:FFToastTypeSuccess] ;
    } failure:^(NSError *error) {
        @strongify(self);
         NSString *msg = [NSString stringWithFormat:@"关注用户%@失败,请重试",self.member.memberName] ;
        [FFToast showToastWithTitle:@"关注失败" message:msg iconImage:nil duration:2 toastType:FFToastTypeError] ;
    }] ;
}

// 屏蔽
- (void)memberBlock{
    @weakify(self);
    [[V2DataManager manager] memberBlockWithMemberName:self.member.memberName success:^(NSString *message) {
        NSString *msg = [NSString stringWithFormat:@"屏蔽用户%@成功",self.member.memberName] ;
        [FFToast showToastWithTitle:@"屏蔽成功" message:msg iconImage:nil duration:2 toastType:FFToastTypeSuccess] ;
    } failure:^(NSError *error) {
        @strongify(self);
        NSString *msg = [NSString stringWithFormat:@"屏蔽用户%@失败,请重试",self.member.memberName] ;
        [FFToast showToastWithTitle:@"屏蔽失败" message:msg iconImage:nil duration:2 toastType:FFToastTypeError] ;
    }] ;
}

#pragma mark --- Setter
- (void)setIsSelf:(BOOL)isSelf{
    _isSelf = isSelf ;
    if(isSelf){
        self.member = [V2UserManager manager].user.member ;
    }
}

- (void)setUsername:(NSString *)username {
    _username = username;
    self.nameLabel.text = username;
}

- (void)setMember:(V2Member *)member {
    _member = member;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:member.memberAvatarLarge]];
    self.signLabel.text = member.memberTagline;
    self.username = member.memberName;
    
    [self.signLabel sizeToFit];
    
    NSMutableArray *profileArray = [[NSMutableArray alloc] init];
    if (self.member.memberTwitter.length > 1) {
        NSDictionary *dict = @{
                               kProfileType: @(V2ProfileCellTypeTwitter),
                               kProfileValue: self.member.memberTwitter
                               };
        [profileArray addObject:dict];
    }
    if (self.member.memberLocation.length > 1) {
        NSDictionary *dict = @{
                               kProfileType: @(V2ProfileCellTypeLocation),
                               kProfileValue: self.member.memberLocation
                               };
        [profileArray addObject:dict];
    }
    if (self.member.memberWebsite.length > 1) {
        NSDictionary *dict = @{
                               kProfileType: @(V2ProfileCellTypeWebsite),
                               kProfileValue: self.member.memberWebsite
                               };
        [profileArray addObject:dict];
    }
    
    self.profileCellArray = profileArray;
    [self.tableView reloadData];
}

#pragma mark --- Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    self.topPanel.top = - (self.tableView.contentInset.top + scrollView.contentOffset.y) + 64;
}

#pragma mark --- Notification
- (void)didSubViewReceiveThemeChangeNotification {
    self.nameLabel.textColor                = kFontColorBlackDark;
    self.signLabel.textColor                = kFontColorBlackLight;
    self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.didGetProfile) {
        NSInteger sectionCount = 3;
        if (self.profileCellArray.count == 0) {
            sectionCount --;
        }
        if (self.member.memberBio.length < 1) {
            sectionCount --;
        }
        return sectionCount;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    if (section == 1) {
        if (self.profileCellArray.count == 0) {
            return 1;
        } else {
            return self.profileCellArray.count;
        }
    }
    if (section == 2) {
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return [V2ProfileBioCell getCellHeightWithBioString:self.member.memberBio];
    } else {
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *profileCellIdentifier = @"profileCellIdentifier";
    V2ProfileCell *profileCell = (V2ProfileCell *)[tableView dequeueReusableCellWithIdentifier:profileCellIdentifier];
    if (!profileCell) {
        profileCell = [[V2ProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:profileCellIdentifier];
    }
    
    static NSString *profileBioCellIdentifier = @"profileBioCellIdentifier";
    V2ProfileBioCell *profileBioCell = (V2ProfileBioCell *)[tableView dequeueReusableCellWithIdentifier:profileBioCellIdentifier];
    if (!profileBioCell) {
        profileBioCell = [[V2ProfileBioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:profileBioCellIdentifier];
    }
    
    profileCell.isTop = NO;
    profileCell.isBottom = NO;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            profileCell.type = V2ProfileCellTypeTopic;
            profileCell.title = @"主题";
            profileCell.isTop = YES;
            return profileCell;
        }
        if (indexPath.row == 1) {
            profileCell.type = V2ProfileCellTypeReply;
            profileCell.title = @"回复";
            profileCell.isBottom = YES;
            return profileCell;
        }
    }
    
    if (indexPath.section == 1) {
        if (self.profileCellArray.count) {
            profileCell.isTop = !indexPath.row;
            profileCell.isBottom = (indexPath.row == (self.profileCellArray.count - 1));
            NSDictionary *cellDict = self.profileCellArray[indexPath.row];
            profileCell.type = [[cellDict objectForKey:kProfileType] integerValue];
            profileCell.title = [cellDict objectForKey:kProfileValue];
            return profileCell;
        } else {
            profileBioCell.bioString = self.member.memberBio;
            return profileBioCell;
        }
    }
    
    if (indexPath.section == 2) {
        profileBioCell.bioString = self.member.memberBio;
        return profileBioCell;
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            V2MemberTopicsViewController *topicsVC = [[V2MemberTopicsViewController alloc] init];
            topicsVC.model = self.member;
            [self.navigationController pushViewController:topicsVC animated:YES];
        }
        if (indexPath.row == 1) {
            V2MemberRepliesViewController *repliesVC = [[V2MemberRepliesViewController alloc] init];
            repliesVC.memberName = self.member.memberName;
            [self.navigationController pushViewController:repliesVC animated:YES];
        }
    }
    
    if (indexPath.section == 1) {
        if (self.profileCellArray.count) {
            NSDictionary *cellDict = self.profileCellArray[indexPath.row];
            V2ProfileCellType type = [[cellDict objectForKey:kProfileType] integerValue];
            NSString *title = [cellDict objectForKey:kProfileValue];
            if (type == V2ProfileCellTypeTwitter) {
                NSArray *urls = [NSArray arrayWithObjects:
                                 @"twitter://user?screen_name={handle}", // Twitter
                                 @"tweetbot:///user_profile/{handle}", // TweetBot
                                 @"echofon:///user_timeline?{handle}", // Echofon
                                 @"twit:///user?screen_name={handle}", // Twittelator Pro
                                 @"x-seesmic://twitter_profile?twitter_screen_name={handle}", // Seesmic
                                 @"x-birdfeed://user?screen_name={handle}", // Birdfeed
                                 @"tweetings:///user?screen_name={handle}", // Tweetings
                                 @"simplytweet:?link=http://twitter.com/{handle}", // SimplyTweet
                                 @"icebird://user?screen_name={handle}", // IceBird
                                 @"fluttr://user/{handle}", // Fluttr
                                 @"http://twitter.com/{handle}",
                                 nil];
                
                UIApplication *application = [UIApplication sharedApplication];
                for (NSString *candidate in urls) {
                    NSURL *url = [NSURL URLWithString:[candidate stringByReplacingOccurrencesOfString:@"{handle}" withString:title]];
                    if ([application canOpenURL:url]){
                        [application openURL:url];
                        return;
                    }
                }
                
            }
            if (type == V2ProfileCellTypeWebsite) {
                if (![title hasPrefix:@"http://"]) {
                    title = [@"http://" stringByAppendingString:title];
                }
                V2WebViewController *webVC = [[V2WebViewController alloc] init];
                webVC.url = title;
                [self.navigationController pushViewController:webVC animated:YES];
            }
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 36}];
    headerView.backgroundColor = kBackgroundColorWhiteDark;
    
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){10, 0, kScreenWidth - 20, 36}];
    label.textColor = kFontColorBlackLight;
    label.font = [UIFont systemFontOfSize:15.0];
    label.text = self.headerTitleArray[section];
    [headerView addSubview:label];
    
    return headerView;
}

@end
