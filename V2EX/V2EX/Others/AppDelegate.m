//
//  AppDelegate.m
//  V2EX
//
//  Created by 杨晴贺 on 21/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "AppDelegate.h"
#import "V2DataManager.h"
#import "V2RootViewController.h"
#import "SINavigationController.h"

#import <UMSocialCore/UMSocialCore.h>
#import <Bugly/Bugly.h>

#if DEBUG
#import <GDPerformanceView/GDPerformanceMonitor.h>
#endif


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#ifdef DEBUG
    [[GDPerformanceMonitor sharedInstance] startMonitoring];
    [[GDPerformanceMonitor sharedInstance] configureWithConfiguration:^(UILabel *textLabel) {
        [textLabel setBackgroundColor:[UIColor blackColor]];
        [textLabel setTextColor:[UIColor whiteColor]];
        [textLabel.layer setBorderColor:[[UIColor blackColor] CGColor]];
    }];
#endif
    [Bugly startWithAppId:kBuglyAppKey];
    self.rootViewController = [[V2RootViewController alloc]init] ;
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds] ;
    self.window.backgroundColor=  [UIColor whiteColor] ;
    self.window.rootViewController = self.rootViewController ;
    [self.window makeKeyAndVisible] ;
    
    [self configUSharePlatforms];

    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application{
#ifdef DEBUG
    [[GDPerformanceMonitor sharedInstance] stopMonitoring];
#endif
}


- (void)configUSharePlatforms
{
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:kWeixinAppKey appSecret:nil redirectURL:nil];

    /* 设置新浪的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:kWeiboAppKey  appSecret:kWeiboAppSecret redirectURL:kWeiboredirect];
}

// 支持所有iOS系统
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    if (kSetting.themeAutoChange) {
        CGFloat brightness = [UIScreen mainScreen].brightness;
        if (brightness < 0.3) {
            kSetting.theme = V2ThemeNight;
        } else {
            kSetting.theme = V2ThemeDefault;
        }
    }
}

#pragma mark - Quick Action

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    if ([shortcutItem.type isEqualToString:V2CheckInQuickAction]) {
        if ([[V2UserManager manager] checkAndLogin]) {
            if ([V2CheckInManager manager].isExpired) {
                [[V2CheckInManager manager] checkInSuccess:^(NSInteger count) {
                    NSString *msg = [NSString stringWithFormat:@"已连续签到 %zd 天", count] ;
                    [FFToast showToastWithTitle:@"签到成功"message:msg iconImage:nil duration:2 toastType:FFToastTypeSuccess];
                } failure:^(NSError *error) {
                    [FFToast showToastWithTitle:@"签到失败"message:@"签到失败,请重试" iconImage:nil duration:2 toastType:FFToastTypeError];
                }];
            } else {
                NSString *msg = [NSString stringWithFormat:@"已连续签到 %zd 天", [V2CheckInManager manager].checkInCount] ;
                [FFToast showToastWithTitle:@"今天已经签到"message:msg iconImage:nil duration:2 toastType:FFToastTypeWarning];
            }
        }
    }
}

@end
