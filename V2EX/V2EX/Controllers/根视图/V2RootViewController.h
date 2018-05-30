//
//  V2RootViewController.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, V2SectionIndex) {
    V2SectionIndexLatest       = 0,
    V2SectionIndexCategories   = 1,
    V2SectionIndexNodes        = 2,
    V2SectionIndexFavorite     = 3,
    V2SectionIndexNotification = 4,
    V2SectionIndexProfile      = 5,
};


@interface V2RootViewController : UIViewController

- (void)showViewControllerAtIndex:(V2SectionIndex)index animated:(BOOL)animated;

@end
