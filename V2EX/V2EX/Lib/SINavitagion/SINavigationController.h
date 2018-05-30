//
//  SINavigationController.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "SINavigationBar.h"

@interface SINavigationPopAnimation : NSObject <UIViewControllerAnimatedTransitioning>
@end

@interface SINavigationPushAnimation : NSObject <UIViewControllerAnimatedTransitioning>
@end

@interface SINavigationController : UINavigationController


@property (nonatomic, assign) BOOL enableInnerInactiveGesture;

+ (void)createNavigationBarForViewController:(UIViewController *)viewController;

@end
