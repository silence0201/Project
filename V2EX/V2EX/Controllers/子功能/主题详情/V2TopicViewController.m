//
//  V2TopicViewController.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/21.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2TopicViewController.h"
#import "SINavigationController.h"
#import "V2WebViewController.h"
#import "SINavigationController.h"
#import "V2NodeViewController.h"

#import "SIQuote.h"

#import "V2TopicToolView.h"
#import "SIActionSheet.h"
#import "V2ActionCellView.h"

#import "V2TopicBodyCell.h"
#import "V2TopicInfoCell.h"
#import "V2TopicTitleCell.h"
#import "V2TopicReplyCell.h"

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <Social/Social.h>
#import <UMSocialCore/UMSocialCore.h>

@interface V2TopicViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIView  *headerView;
@property (nonatomic, strong) UILabel *nodeNameLabel;
@property (nonatomic, strong) UIView  *headerContainView;

@property (nonatomic, strong) SIBarButtonItem *leftBarItem;
@property (nonatomic, strong) SIBarButtonItem *addBarItem;
@property (nonatomic, strong) SIBarButtonItem *doneBarItem;
@property (nonatomic, strong) SIBarButtonItem *activityBarItem;

@property (nonatomic, strong) V2TopicToolView *toolBarView;
@property (nonatomic, strong) UITextField  *titleTextField;

@property (nonatomic, strong) SIActionSheet *actionSheet;
@property (nonatomic, strong) SIActionSheet *shareActionSheet;

@property (nonatomic, strong) NSMutableArray<V2Reply *> *replyList;
@property (nonatomic, strong) V2Reply *selectedReplyModel;
@property (nonatomic, strong) V2Node *nodeModel;

@property (nonatomic, assign) BOOL needsCreate;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePanRecognizer;
@property (nonatomic, copy) NSString *token;

@end

@implementation V2TopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.needsCreate = YES ;
    self.refreshEnabled =  NO ;
    self.view.backgroundColor = kBackgroundColorWhite;
    [self setupBarItems];
    [self setupTableView];
    [self setupHeaderView];
    [self setupToolbar] ;
    [self setupNotifications];
    
    if (self.isPreview) {
        [self createNavigationBar];
        self.naviItem.title = @"预览";
        self.naviItem.titleLabel.centerY = 64/2;
    } else {
        self.naviItem.leftBarButtonItem = self.leftBarItem;
        self.naviItem.rightBarButtonItem = self.addBarItem;
        if (self.model) {
            self.naviItem.title = self.model.topicTitle;
            self.nodeModel = self.model.topicNode;
        } else {
            self.naviItem.title = @"Topic";
        }
    }
    
    if (!self.model.topicContent && !self.isCreate) {
        [self loadTopic] ;
    }
    
    
    @weakify(self);
    self.loadMoreBlock =^{
        @strongify(self);
        [self loadReply];
    };
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated] ;
    if (self.isCreate) {
        [self setupNavigationBar];
        [self.toolBarView showReplyViewWithQuotes:nil animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated] ;
    if(self.isCreate){
        [self updateNaviBarStatus];
    }
    if (!self.replyList && !self.isCreate) {
        @weakify(self);
        [self bk_performBlock:^(id obj) {
            @strongify(self);
            [self beginLoadMore];
            self.loadMoreBlock = nil ;
        } afterDelay:0.5];
    }
}

- (void)setupBarItems{
    @weakify(self);
    self.leftBarItem = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] handler:^(id sender) {
        @strongify(self);
        if (self.toolBarView.isShowing) {
            [self.toolBarView popToolBar];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    self.addBarItem = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_more"] handler:^(id sender) {
        @strongify(self);
        V2ActionCellView *shareAction = [[V2ActionCellView alloc] initWithTitles:@[@"微信",@"朋友圈",@"Twitter",@"微博"] imageNames:@[@"share_wechat_friends", @"share_wechat_moments", @"share_twitter", @"share_weibo"]];
        V2ActionCellView *actionAction = [[V2ActionCellView alloc] initWithTitles:@[@"忽略", @"收藏", @"感谢", @"Safari"] imageNames:@[@"action_forbidden", @"action_favorite", @"action_thank", @"action_safari"]];
        
        self.actionSheet = [[SIActionSheet alloc] initWithTitles:@[@"分享", @""] customViews:@[shareAction, actionAction] buttonTitles:@"回复", nil];
        shareAction.actionSheet = self.actionSheet;
        actionAction.actionSheet = self.actionSheet;
        
        @weakify(self);
        [self.actionSheet setButtonHandler:^{
            @strongify(self);
            [self.toolBarView showReplyViewWithQuotes:nil animated:YES];
        } forIndex:0];
        
        [shareAction setButtonHandler:^{
            @strongify(self);
            [self shareToWeixin] ;
        } forIndex:0];
        
        [shareAction setButtonHandler:^{
            @strongify(self);
            [self shareToFriends] ;
        } forIndex:1];
        
        [shareAction setButtonHandler:^{
            @strongify(self);
            [self shareToTwitter] ;
        } forIndex:2];
        
        [shareAction setButtonHandler:^{
            @strongify(self);
            [self shareToWeibo] ;
        } forIndex:3];
        
        
        [actionAction setButtonHandler:^{
            @strongify(self);
            [self ignoreTopic];
        } forIndex:0];
        
        [actionAction setButtonHandler:^{
            @strongify(self);
            [self favTopic];
        } forIndex:1];
        
        [actionAction setButtonHandler:^{
            @strongify(self);
            [self thankTopic];
        } forIndex:2];
        
        [actionAction setButtonHandler:^{
            @strongify(self);
            [self openWithWeb];
        } forIndex:3];
        [self.actionSheet show:YES];
    }];
    
    self.doneBarItem = [[SIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_done"] handler:^(id sender) {
        @strongify(self);
        if (self.toolBarView.replyContentString) {
            if (self.isCreate) {
                [self topicCreate:self.titleTextField.text content:self.toolBarView.replyContentString] ;
            } else {
                [self replyCreate:self.toolBarView.replyContentString] ;
            }
        }
    }];

}

- (void)setupTableView{
    self.tableView  = [[SIEmptyTableView alloc] initWithFrame:self.view.frame];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0) ;
    [self.view addSubview:self.tableView];
}

- (void)setupHeaderView{
    self.headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 36}];
    
    self.headerContainView = [[UIView alloc] initWithFrame:(CGRect){0, self.headerView.height - 36, kScreenWidth, 36}];
    self.headerContainView.backgroundColor = kBackgroundColorWhiteDark;
    [self.headerView addSubview:self.headerContainView];
    
    UIButton *headerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    headerButton.frame = (CGRect){0, 0, _headerContainView.width, _headerContainView.height};
    [self.headerView addSubview:headerButton];
    
    self.nodeNameLabel = [[UILabel alloc] initWithFrame:(CGRect){10, 0, 200, 36}];
    self.nodeNameLabel.textColor = kFontColorBlackLight;
    self.nodeNameLabel.font = [UIFont systemFontOfSize:15];
    self.nodeNameLabel.userInteractionEnabled = NO;
    [_headerContainView addSubview:self.nodeNameLabel];
    
    UIImageView *rightArrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Arrow"]];
    rightArrowImageView.userInteractionEnabled = NO;
    rightArrowImageView.frame = (CGRect){0, 13, 5, 10};
    rightArrowImageView.left = _headerContainView.width - rightArrowImageView.width - 10;
    [_headerContainView addSubview:rightArrowImageView];
    
    self.tableView.tableHeaderView = self.headerView;
    
    // Handles
    @weakify(self);
    [headerButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        V2NodeViewController *nodeVC = [[V2NodeViewController alloc] init];
        nodeVC.model = self.nodeModel;
        [self.navigationController pushViewController:nodeVC animated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupToolbar{
    self.toolBarView = [[V2TopicToolView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, self.view.height}];
    self.toolBarView.create = self.isCreate;
    [self.view addSubview:self.toolBarView];
    
    @weakify(self);
    [self.toolBarView setContentIsEmptyBlock:^(BOOL isEmpty) {
        @strongify(self);
        [self updateNaviBarStatus];
    }];
}

- (void)setupNotifications{
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:kShowReplyTextViewNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        self.naviItem.rightBarButtonItem = self.doneBarItem;
        [self updateNaviBarStatus];
        __block UIImage *screenImage = [self.view snapshotImage];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIColor *blurColor = [UIColor colorWithWhite:0.98 alpha:0.87f];
            if (kCurrentTheme == V2ThemeNight) {
                blurColor = [UIColor colorWithWhite:0.028 alpha:0.870];
            }
            screenImage = [screenImage imageByBlurRadius:4.3 tintColor:blurColor tintMode:kCGBlendModeNormal saturation:2.0 maskImage:nil] ;
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                self.toolBarView.blurredBackgroundImage = screenImage;
            });
        });
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kHideReplyTextViewNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        self.naviItem.rightBarButtonItem = self.addBarItem;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kThemeDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        self.nodeNameLabel.textColor = kFontColorBlackLight;
        self.headerContainView.backgroundColor  = kBackgroundColorWhiteDark ;
    }] ;
}

- (void)setupNavigationBar {
    
    if (!self.needsCreate) {
        return;
    }
    
    self.needsCreate = NO;
    
    self.titleTextField = [[UITextField alloc] initWithFrame:CGRectZero];
    self.titleTextField.font = [UIFont systemFontOfSize:17];
    self.titleTextField.textColor = kNavigationBarTintColor;
    self.titleTextField.textAlignment = NSTextAlignmentCenter;
    self.titleTextField.placeholder = @"输入标题";
    [self.naviBar addSubview:self.titleTextField];
    
    NSUInteger otherButtonWidth = self.naviItem.leftBarButtonItem.view.width + self.naviItem.rightBarButtonItem.view.width;
    self.titleTextField.width = kScreenWidth - otherButtonWidth - 20;
    self.titleTextField.height = 44;
    self.titleTextField.centerY = 42;
    self.titleTextField.centerX = kScreenWidth/2;
    
    // handles
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:UITextFieldTextDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        [self updateNaviBarStatus];
    }];
    
}

#pragma mark --- Load Data
- (void)loadTopic{
    @weakify(self);
    [[V2DataManager manager] getTopicWithTopicId:self.model.topicId success:^(V2Topic *model) {
        @strongify(self);
        self.model = model;
    } failure:^(NSError *error) {
        
    }] ;
}

- (void)loadReply{
    @weakify(self);
    [[V2DataManager manager] getReplyListWithTopicId:self.model.topicId success:^(NSArray<V2Reply *> *list) {
        @strongify(self);
        NSMutableArray *replys = [list mutableCopy] ;
        [replys reverse] ;
        self.replyList = replys;
        [self endLoadMore];
    } failure:^(NSError *error) {
        @strongify(self);
        [self endLoadMore];
    }] ;
}

- (void)replyCreate:(NSString *)conten{
    @weakify(self);
    [self naviBeginRefreshing];
    [[V2DataManager manager]replyCreateWithTopicId:self.model.topicId content:conten success:^(NSString *message) {
        @strongify(self);
        [self naviEndRefreshing];
        [[NSNotificationCenter defaultCenter] postNotificationName:kReplySuccessNotification object:nil];
        self.naviItem.rightBarButtonItem = self.addBarItem;
        [self.toolBarView clearTextView];
        // update State Count
        NSInteger replyCount = [self.model.topicReplyCount integerValue] + 1;
        self.model.topicReplyCount = [NSString stringWithFormat:@"%ld", (long)replyCount];
        [[V2TopicStateManager manager] saveStateForTopicModel:self.model];
        [self beginLoadMore];
    } failure:^(NSError *error) {
        [self naviEndRefreshing];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kReplySuccessNotification object:nil];
        NSString *msg = [NSString stringWithFormat:@"回复主题%@失败,请重试",self.model.topicTitle] ;
        [FFToast showToastWithTitle:@"回复失败" message:msg iconImage:nil duration:2 toastType:FFToastTypeError] ;
    }] ;
}

- (void)topicCreate:(NSString *)title content:(NSString *)content{
    @weakify(self);
    [self naviBeginRefreshing];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [[V2DataManager manager] topicCreateWithNodeName:self.nodeModel.nodeName title:title content:content success:^(NSString *message) {
        @strongify(self);
        [self naviEndRefreshing];
        self.create = NO;
        self.toolBarView.create = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kReplySuccessNotification object:nil];
        
        self.naviItem.rightBarButtonItem = self.addBarItem;
        [self.toolBarView clearTextView];
        
        V2Topic *topicModel = [[V2Topic alloc] init];
        topicModel.topicId = message;
        topicModel.topicNode = self.nodeModel;
        self.model = topicModel;
        
        [self loadTopic] ;
        [self beginLoadMore];
    } failure:^(NSError *error) {
        @strongify(self);
        [self naviEndRefreshing];
        [[NSNotificationCenter defaultCenter] postNotificationName:kReplySuccessNotification object:nil];
        NSString *msg = [NSString stringWithFormat:@"在结点%@发帖失败,请重试",self.nodeModel.nodeName] ;
        [FFToast showToastWithTitle:@"发帖失败" message:msg iconImage:nil duration:2 toastType:FFToastTypeError] ;
    }] ;
}

#pragma mark - Setter

- (void)setPreview:(BOOL)preview {
    _preview = preview;
    
    if (self.isPreview) {
        [self createNavigationBar];
        self.naviItem.title = @"预览";
        self.naviItem.titleLabel.centerY = 64/2;
    } else {
        self.naviItem.leftBarButtonItem = self.leftBarItem;
        self.naviItem.rightBarButtonItem = self.addBarItem;
        
        if (self.model) {
            self.naviItem.title = self.model.topicTitle;
            self.nodeModel = self.model.topicNode;
        } else {
            self.naviItem.title = @"Topic";
        }
    }
}

#pragma mark --- Action
- (void)shareToWeixin{
    [self shareWebPageToPlatformType:UMSocialPlatformType_WechatSession];
}

- (void)shareToFriends{
    [self shareWebPageToPlatformType:UMSocialPlatformType_WechatTimeLine];
}

- (void)shareToWeibo{
    [self shareWebPageToPlatformType:UMSocialPlatformType_Sina] ;
}


- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    NSString *shareWeboString = [NSString stringWithFormat:@"#V2EX# %@ ", self.model.topicTitle];
    NSString* thumbURL =  @"https://mobile.umeng.com/images/pic/home/social/img-1.png";
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"来自V2EX客户端" descr:shareWeboString thumImage:thumbURL];
    //设置网页地址
    NSString *urlStr = [NSString stringWithFormat:@"https://www.v2ex.com/t/%@",self.model.topicId] ;
    shareObject.webpageUrl =urlStr;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            NSString *msg ;
            if(error.code == 2009){
                msg = @"用户取消分享" ;
            }else{
                msg = error.userInfo[@"message"] ;
            }
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
            [FFToast showToastWithTitle:@"分享失败" message:msg iconImage:nil duration:2 toastType:FFToastTypeError] ;
        }else{
            [FFToast showToastWithTitle:@"分享成功" message:nil iconImage:nil duration:2 toastType:FFToastTypeSuccess] ;
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
    }];
}


- (void)shareToTwitter{
    SLComposeViewController *composeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    NSString *shareString = [NSString stringWithFormat:@"#V2EX %@ https://www.v2ex.com/t/%@ ", self.model.topicTitle, self.model.topicId];
    [composeViewController setInitialText:shareString];
    
    composeViewController.completionHandler = ^(SLComposeViewControllerResult result){
        
        switch (result)
        {
            case SLComposeViewControllerResultDone:
                [FFToast showToastWithTitle:@"分享成功" message:nil iconImage:nil duration:2 toastType:FFToastTypeSuccess] ;
                break;
            case SLComposeViewControllerResultCancelled:
                [FFToast showToastWithTitle:@"分享失败" message:@"用户取消" iconImage:nil duration:2 toastType:FFToastTypeError] ;
                break;
            default:
                [FFToast showToastWithTitle:@"分享失败" message:nil iconImage:nil duration:2 toastType:FFToastTypeError] ;
                break;
        }
        
    };
    
    [self presentViewController:composeViewController
                       animated:NO
                     completion:nil];

}

- (void)ignoreTopic{
    @weakify(self);
    [[V2DataManager manager] ignoreTopicWithTopicId:self.model.topicId success:^(NSString *message) {
        @strongify(self);
        NSString *msg = [NSString stringWithFormat:@"忽略主题成功"] ;
        [FFToast showToastWithTitle:@"忽略成功" message:msg iconImage:nil duration:2 toastType:FFToastTypeSuccess] ;
        [self.navigationController popViewControllerAnimated:YES];
        [self bk_performBlock:^(id obj) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kIgnoreTopicSuccessNotification object:self.model];
        } afterDelay:0.6];
    } failure:^(NSError *error) {
        NSString *msg = [NSString stringWithFormat:@"忽略主题失败,请重试"] ;
        [FFToast showToastWithTitle:@"忽略失败" message:msg iconImage:nil duration:2 toastType:FFToastTypeError] ;
    }];

}

- (void)favTopic{
    @weakify(self);
    [self getTokenWithBlock:^(NSString *token) {
        @strongify(self);
        
        [[V2DataManager manager] topicFavWithTopicId:self.model.topicId token:token success:^(NSString *message) {
            NSString *msg = [NSString stringWithFormat:@"收藏主题成功"] ;
            [FFToast showToastWithTitle:@"收藏成功" message:msg iconImage:nil duration:2 toastType:FFToastTypeSuccess] ;
        } failure:^(NSError *error) {
            NSString *msg = [NSString stringWithFormat:@"收藏主题失败,请重试"] ;
            [FFToast showToastWithTitle:@"收藏失败" message:msg iconImage:nil duration:2 toastType:FFToastTypeError] ;
        }];
        
    }];

}

- (void)thankTopic{
    [self getTokenWithBlock:^(NSString *token) {
        [[V2DataManager manager] topicThankWithTopicId:self.model.topicId token:token success:^(NSString *message) {
            NSString *msg = [NSString stringWithFormat:@"感谢主题成功"] ;
            [FFToast showToastWithTitle:@"感谢成功" message:msg iconImage:nil duration:2 toastType:FFToastTypeSuccess] ;
        } failure:^(NSError *error) {
            NSString *msg = [NSString stringWithFormat:@"感谢主题失败,请重试"] ;
            [FFToast showToastWithTitle:@"感谢失败" message:msg iconImage:nil duration:2 toastType:FFToastTypeError] ;
        }];
    }] ;
}

- (void)openWithWeb{
    V2WebViewController *webVC = [[V2WebViewController alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"https://v2ex.com/t/%@", self.model.topicId];
    webVC.url = urlString;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)thankReplyActionWithReplyId:(NSString *)replyId{
    [self getTokenWithBlock:^(NSString *token) {
        [[V2DataManager manager] replyThankWithReplyId:replyId token:token success:^(NSString *message) {
            NSString *msg = [NSString stringWithFormat:@"感谢回帖成功"] ;
            [FFToast showToastWithTitle:@"感谢成功" message:msg iconImage:nil duration:2 toastType:FFToastTypeSuccess] ;
        } failure:^(NSError *error) {
            NSString *msg = [NSString stringWithFormat:@"感谢回帖失败,请重试"] ;
            [FFToast showToastWithTitle:@"感谢失败" message:msg iconImage:nil duration:2 toastType:FFToastTypeError] ;
        }];
    }];
}

- (void)getTokenWithBlock:(void (^)(NSString *token))block {
    if (self.token) {
        block(self.token);
    } else {
        @weakify(self);
        [[V2DataManager manager] getTopicTokenWithTopicId:self.model.topicId success:^(NSString *token) {
            @strongify(self);
            self.token = token;
            block(token);
        } failure:^(NSError *error) {
            block(nil);
        }];
    }
}

- (void)updateNaviBarStatus{
    if ((!self.toolBarView.isContentEmpty && self.titleTextField.text.length > 0) || (!self.isCreate && !self.toolBarView.isContentEmpty)) {
        self.doneBarItem.enabled = YES;
    } else {
        self.doneBarItem.enabled = NO;
    }
}

#pragma mark --- Data
- (void)setModel:(V2Topic *)model{
    _model = model;
    self.naviItem.title = model.topicTitle;
    if (model.topicTitle && self.titleTextField) {
        if (self.titleTextField) {
            [self.titleTextField removeFromSuperview];
            self.titleTextField = nil;
        }
    }
    self.nodeModel = model.topicNode;
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    if (self.model.topicReplyCount) {
        [[V2TopicStateManager manager] saveStateForTopicModel:self.model];
    }
    self.model.state = [[V2TopicStateManager manager] getTopicStateWithTopicModel:self.model];
}

- (void)setNodeModel:(V2Node *)nodeModel{
    _nodeModel = nodeModel;
    self.nodeNameLabel.text = self.nodeModel.nodeTitle;
}

- (void)setReplyList:(NSMutableArray<V2Reply *> *)replyList {
    BOOL isFirstSet = (_replyList == nil);
    _replyList = replyList;
    if (isFirstSet) {
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark --- Nav
- (void)naviBeginRefreshing {
    UIActivityIndicatorView *activityView;
    for (UIView *view in self.naviBar.subviews) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            activityView = (UIActivityIndicatorView *)view;
        }
        if ([view isEqual:self.naviItem.rightBarButtonItem.view]) {
            [view removeFromSuperview];
        }
    }
    if (!activityView) {
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView setColor:[UIColor blackColor]];
        activityView.frame = (CGRect){kScreenWidth - 42, 25, 35, 35};
        [self.naviBar addSubview:activityView];
    }
    [activityView startAnimating];
}


- (void)naviEndRefreshing {
    UIActivityIndicatorView *activityView;
    for (UIView *view in self.naviBar.subviews) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            activityView = (UIActivityIndicatorView *)view;
        }
    }
    if (self.naviItem.rightBarButtonItem) {
        [self.naviBar addSubview:self.naviItem.rightBarButtonItem.view];
    }
    [activityView stopAnimating];
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else {
        return self.replyList.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return [V2TopicTitleCell getCellHeightWithTopic:self.model];
                break;
            case 1:
                return [V2TopicInfoCell getCellHeightWithTopic:self.model];
                break;
            case 2:
                return [V2TopicBodyCell getCellHeightWithTopic:self.model];
                break;
            default:
                break;
        }
    }
    
    if (indexPath.section == 1) {
        V2Reply *model = self.replyList[indexPath.row];
        return [V2TopicReplyCell getCellHeightWithReply:model];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *titleCellIdentifier = @"titleCellIdentifier";
    V2TopicTitleCell *titleCell = (V2TopicTitleCell *)[tableView dequeueReusableCellWithIdentifier:titleCellIdentifier];
    if (!titleCell) {
        titleCell = [[V2TopicTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:titleCellIdentifier];
        titleCell.navi = self.navigationController;
    }
    
    static NSString *infoCellIdentifier = @"infoCellIdentifier";
    V2TopicInfoCell *infoCell = (V2TopicInfoCell *)[tableView dequeueReusableCellWithIdentifier:infoCellIdentifier];
    if (!infoCell) {
        infoCell = [[V2TopicInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infoCellIdentifier];
        infoCell.navi = self.navigationController;
    }
    
    static NSString *bodyCellIdentifier = @"bodyCellIdentifier";
    V2TopicBodyCell *bodyCell = (V2TopicBodyCell *)[tableView dequeueReusableCellWithIdentifier:bodyCellIdentifier];
    if (!bodyCell) {
        bodyCell = [[V2TopicBodyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bodyCellIdentifier];
        bodyCell.navi = self.navigationController;
    }
    
    static NSString *replyCellIdentifier = @"replyCellIdentifier";
    V2TopicReplyCell *replyCell = (V2TopicReplyCell *)[tableView dequeueReusableCellWithIdentifier:replyCellIdentifier];
    if (!replyCell) {
        replyCell = [[V2TopicReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:replyCellIdentifier];
        replyCell.navi = self.navigationController;
    }
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return [self setupTitleCellWithCell:titleCell IndexPath:indexPath];
                break;
            case 1:
                return [self setupInfoCellWithCell:infoCell IndexPath:indexPath];
                break;
            case 2:
                return [self setupBodyCellWithCell:bodyCell IndexPath:indexPath];
                break;
            default:
                break;
        }
    }
    if (indexPath.section == 1) {
        return [self setupReplyCellWithCell:replyCell IndexPath:indexPath];
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        V2Reply *model = self.replyList[indexPath.row];
        self.actionSheet = [[SIActionSheet alloc] initWithTitles:@[model.replyCreator.memberName] customViews:nil buttonTitles:@"回复", @"感谢", nil];
        @weakify(self);
        [self.actionSheet setButtonHandler:^{
            @strongify(self);
            SIQuote *quote = [[SIQuote alloc] init] ;
            quote.string = model.replyCreator.memberName;
            quote.type = SIQuoteTypeUser;
            [self setNavigationBarHidden:NO animated:YES];
            [self.toolBarView showReplyViewWithQuotes:@[quote] animated:YES];
        } forIndex:0];
        
        [self.actionSheet setButtonHandler:^{
            @strongify(self);
            [self thankReplyActionWithReplyId:model.replyId];
        } forIndex:1];
        [self.actionSheet show:YES];
    }
}

#pragma mark - Configure TableCell

- (V2TopicTitleCell *)setupTitleCellWithCell:(V2TopicTitleCell *)cell IndexPath:(NSIndexPath *)indexPath {
    cell.model = self.model;
    return cell;
}

- (V2TopicInfoCell *)setupInfoCellWithCell:(V2TopicInfoCell *)cell IndexPath:(NSIndexPath *)indexPath {
    cell.model = self.model;
    return cell;
}

- (V2TopicBodyCell *)setupBodyCellWithCell:(V2TopicBodyCell *)cell IndexPath:(NSIndexPath *)indexPath {
    cell.model = self.model;
    @weakify(self);
    [cell setReloadCellBlock:^{
        @strongify(self);
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }];
    return cell;
}

- (V2TopicReplyCell *)setupReplyCellWithCell:(V2TopicReplyCell *)cell IndexPath:(NSIndexPath *)indexPath {
    V2Reply *model = self.replyList[indexPath.row];
    cell.model = model;
    cell.selectedReplyModel = self.selectedReplyModel;
    cell.replyList = self.replyList;
    @weakify(self);
    [cell setReloadCellBlock:^{
        @strongify(self);
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }];
    
    [cell setLongPressedBlock:^{
        @strongify(self);
        [[NSNotificationCenter defaultCenter] postNotificationName:kSelectMemberNotification object:model];
        self.selectedReplyModel = model;
    }];
    return cell;
}


#pragma mark --- Preview
- (NSArray <id <UIPreviewActionItem>> *)previewActionItems {
    UIPreviewAction *openAction = [UIPreviewAction actionWithTitle:@"打开" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        V2TopicViewController *vc = (V2TopicViewController *)previewViewController;

        V2TopicViewController *topicVC = [[V2TopicViewController alloc] init];
        topicVC.model = vc.model;
        AppDelegate *app = (AppDelegate *)([UIApplication sharedApplication].delegate) ;
        [app.currentNavigationController pushViewController:topicVC animated:YES] ;
    }];
    
    
    
    UIPreviewAction *openWithWebAction = [UIPreviewAction actionWithTitle:@"用浏览器打开" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        V2TopicViewController *vc = (V2TopicViewController *)previewViewController;
        V2WebViewController *webVC = [[V2WebViewController alloc] init];
        webVC.url = [NSString stringWithFormat:@"https://v2ex.com/t/%@", vc.model.topicId];
        AppDelegate *app = (AppDelegate *)([UIApplication sharedApplication].delegate) ;
        [app.currentNavigationController pushViewController:webVC animated:YES] ;
    }];
    
    return @[openAction, openWithWebAction];
    
}

@end
