//
//  V2WebViewController.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/21.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2WebViewController.h"
#import "SINavigationController.h"
#import "SIActionSheet.h"
#import "UIImage+Tint.h"
#import <WebKit/WebKit.h>

@interface V2WebViewController ()<WKNavigationDelegate>

@property (nonatomic, strong) SIBarButtonItem *backBarItem;
@property (nonatomic, strong) SIBarButtonItem *actionBarItem;

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) SIActionSheet *actionSheet;

@property (nonatomic, strong) UIView *toolBar;

@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIButton *refreshButton;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation V2WebViewController

- (void)setupWebView{
    self.webView = [[WKWebView alloc] init];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque=NO;
    self.webView.navigationDelegate = self ; 
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 44.0f, 0);
    [self.view addSubview:self.webView];
}

- (void)setupToolBar{
    self.toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,44)];
    self.toolBar.backgroundColor = kNavigationBarColor;
    
    UIView *topLineView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0.5}];
    topLineView.backgroundColor = kNavigationBarLineColor;
    [self.toolBar addSubview:topLineView];
    
    self.prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.prevButton  setImage:[UIImage imageNamed:@"Browser_Icon_Backward"].imageForCurrentTheme forState:UIControlStateNormal];
    [self.prevButton  addTarget:self action:@selector(prevPage) forControlEvents:UIControlEventTouchUpInside];
    
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.nextButton  setImage:[UIImage imageNamed:@"Browser_Icon_Forward"].imageForCurrentTheme forState:UIControlStateNormal];
    [self.nextButton  addTarget:self action:@selector(nextPage) forControlEvents:UIControlEventTouchUpInside];
    
    self.refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.refreshButton  setImage:[UIImage imageNamed:@"Browser_Icon_Refresh"].imageForCurrentTheme forState:UIControlStateNormal];
    [self.refreshButton  addTarget:self action:@selector(refreshPage) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.toolBar addSubview:self.prevButton];
    [self.toolBar addSubview:self.nextButton];
    [self.toolBar addSubview:self.refreshButton];
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.hidden = YES;
    
    [self.toolBar addSubview:self.activityIndicatorView];
    
    [self.view addSubview:self.toolBar];

}

- (void)setupBarItems{
    @weakify(self)
    self.backBarItem = [[SIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navi_back"] handler:^(id sender) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
    }] ;
    
    self.actionBarItem  = [[SIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"navi_more"] handler:^(id sender) {
        @strongify(self);
        self.actionSheet = [[SIActionSheet alloc]initWithTitles:@[@"操作"] customViews:nil buttonTitles:@"复制连接",@"用Safari打开",nil] ;
        [self.actionSheet setButtonHandler:^{
            @strongify(self);
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard] ;
            [pasteboard setString:self.url] ;
        } forIndex:0] ;
        
        [self.actionSheet setButtonHandler:^{
            @strongify(self);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.url]];
        } forIndex:1] ;
        [self.actionSheet show:YES] ;
    }] ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupWebView] ;
    [self setupToolBar] ;
    [self setupBarItems] ;
    
    self.view.backgroundColor = kBackgroundColorWhite;
    
    self.naviItem.leftBarButtonItem = self.backBarItem ;
    self.naviItem.rightBarButtonItem = self.actionBarItem ;
    
    if(!self.url){
        _url = @"https://www.v2ex.com" ;
    }
    NSURL *newUrl = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:newUrl];
    [self.webView loadRequest:request];
}

- (void)dealloc {
    [self.webView stopLoading];
    [self.webView removeFromSuperview];
    self.webView = nil;
}

#pragma mark --- Layout
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGRect rect = self.view.bounds;
    self.webView.frame = (CGRect){0, 44, kScreenWidth, kScreenHeight - 44};
    
    self.toolBar.frame = CGRectMake(0, rect.size.height-44, rect.size.width, 44);
    self.prevButton.frame = CGRectMake(15, 12, 20, 20);
    self.refreshButton.frame = CGRectMake(kScreenWidth/2 - 10, 12, 20, 20);
    self.nextButton.frame = CGRectMake(kScreenWidth - 35, 12, 20, 20);
    
    self.activityIndicatorView.center = self.refreshButton.center;
}


#pragma mark --- WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [self startLoading];
    [self checkButtonEnabled];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [self stopLoading];
    [self checkButtonEnabled];
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
        self.title = title;
        self.naviItem.title =title;
    }] ;
}

#pragma mark --- Action
- (void)prevPage {
    [self.webView goBack];
}

- (void)nextPage {
    [self.webView goForward];
}

- (void)refreshPage {
    [self.webView stopLoading];
    [self.webView reload];
}

- (void)setPrevButtonEnabled:(BOOL)enabled {
    self.prevButton.alpha = enabled ? 1.0 : 0.7f;
    self.prevButton.enabled = enabled;
}

- (void)setNextButtonEnabled:(BOOL)enabled {
    self.nextButton.alpha = enabled ? 1.0 : 0.7f;
    self.nextButton.enabled = enabled;
}

- (void)checkButtonEnabled {
    BOOL canback = [self.webView canGoBack];
    BOOL canforworld = [self.webView canGoForward];
    
    [self setPrevButtonEnabled:canback];
    [self setNextButtonEnabled:canforworld];
}

#pragma mark - activityIndicatorView
- (void)startLoading {
    self.refreshButton.hidden = YES;
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)stopLoading {
    self.refreshButton.hidden = NO;
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden  = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
