//
//  V2UserManager.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface V2UserManager : V2BaseManager

@property (nonatomic, strong) V2User *user;

/// 用户退出
- (void)UserLogout ;

/// 检查并登录
- (BOOL)checkAndLogin ;

@end
