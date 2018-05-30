//
//  V2UserManager.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2UserManager.h"
#import "AppDelegate.h"
#import "V2LoginViewController.h"


static NSString *const kUsername = @"username";
static NSString *const kUserid = @"userid";
static NSString *const kAvatarURL = @"avatarURL";
static NSString *const kUserIsLogin = @"userIsLogin";

static NSString *const kLoginPassword = @"p";
static NSString *const kLoginUsername = @"u";

@implementation V2UserManager

- (instancetype)init{
    if (self = [super init]) {
        BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserIsLogin] boolValue];
        if (isLogin) {
            V2User *user = [[V2User alloc] init];
            user.login = YES;
            V2Member *member = [[V2Member alloc] init];
            user.member = member;
            user.member.memberName = [[NSUserDefaults standardUserDefaults] objectForKey:kUsername];
            user.member.memberId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserid];
            user.member.memberAvatarLarge = [[NSUserDefaults standardUserDefaults] objectForKey:kAvatarURL];
            _user = user;
        }
    }
    return self ;
}

+ (instancetype)manager{
    static V2UserManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[V2UserManager alloc] init];
    });
    return manager;
}

- (void)setUser:(V2User *)user {
    _user = user;
    if (user) {
        self.user.login = YES;
        [[NSUserDefaults standardUserDefaults] setObject:user.member.memberName forKey:kUsername];
        [[NSUserDefaults standardUserDefaults] setObject:user.member.memberId forKey:kUserid];
        [[NSUserDefaults standardUserDefaults] setObject:user.member.memberAvatarLarge forKey:kAvatarURL];
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserIsLogin];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUsername];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserid];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAvatarURL];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserIsLogin];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (void)UserLogout {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    self.user = nil;
    [[V2CheckInManager manager] removeStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutSuccessNotification object:nil];
    
}

- (BOOL)checkAndLogin{
    if (!_user) {
        AppDelegate *app =  (AppDelegate *)[UIApplication sharedApplication].delegate ;
        [FFToast showToastWithTitle:@"请先登录" message:nil iconImage:nil duration:0.3 toastType:FFToastTypeWarning] ;
        V2LoginViewController *loginViewController = [[V2LoginViewController alloc] init];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [app.window.rootViewController presentViewController:loginViewController animated:YES completion:nil] ;
        });
        return NO;
    }
    
    return YES;
}

@end
