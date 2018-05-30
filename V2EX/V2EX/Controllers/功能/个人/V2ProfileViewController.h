//
//  V2ProfileViewController.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "SIRefreshControl.h"

@interface V2ProfileViewController : SIRefreshControl

@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, strong) V2Member *member;

@end
