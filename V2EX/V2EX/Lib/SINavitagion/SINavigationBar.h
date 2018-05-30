//
//  SINavigationBar.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SINavigationItem.h"
#import "SIBarButtonItem.h"

@interface SINavigationBar : UIView

@end


@interface UIViewController (SINavigation)

@property (nonatomic, strong) SINavigationItem *naviItem;
@property (nonatomic, strong) UIView *naviBar;

@property(nonatomic, getter = isNavigationBarHidden) BOOL navigationBarHidden;
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;



- (SIBarButtonItem *)createBackItem;

- (void)naviBeginRefreshing;
- (void)naviEndRefreshing;


- (void)createNavigationBar;

@end
