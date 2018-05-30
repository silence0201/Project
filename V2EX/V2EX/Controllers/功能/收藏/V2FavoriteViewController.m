//
//  V2FavoriteViewController.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2FavoriteViewController.h"
#import "V2LoginViewController.h"

@interface V2FavoriteViewController ()

@end

@implementation V2FavoriteViewController

- (void)viewDidLoad {
    self.favorite = YES ;
    self.needLogin = YES ;

    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLoginSuccessNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [self beginRefresh] ;
        @weakify(self);
        self.tableView.title = @"刷新失败" ;
        self.tableView.buttonTitle = @"点击刷新" ;
        self.tableView.emptyClickAction = ^(){
            @strongify(self) ;
            [self beginRefresh];
        } ;
    }] ;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLogoutSuccessNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        self.tableView.title = @"查看收藏信息需要登录" ;
        self.tableView.buttonTitle = @"登录" ;
        @weakify(self);
        self.tableView.emptyClickAction = ^(){
            @strongify(self) ;
            [self presentViewController:[V2LoginViewController new] animated:YES completion:nil] ;
        } ;
        [self.topicList removeAllObjects] ;
        [self.tableView reloadData] ;
    }] ;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self] ;
}


@end
