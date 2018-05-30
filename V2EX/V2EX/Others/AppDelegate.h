//
//  AppDelegate.h
//  V2EX
//
//  Created by 杨晴贺 on 21/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SINavigationController,V2RootViewController ;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) V2RootViewController *rootViewController;
@property (nonatomic, assign) SINavigationController *currentNavigationController;


@end

