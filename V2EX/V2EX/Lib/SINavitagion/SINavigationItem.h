//
//  SINavigationItem.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SIBarButtonItem ;
@interface SINavigationItem : NSObject

@property (nonatomic, strong  ) SIBarButtonItem *leftBarButtonItem;
@property (nonatomic, strong  ) SIBarButtonItem *rightBarButtonItem;
@property (nonatomic, copy    ) NSString        *title;

@property (nonatomic, readonly) UIView          *titleView;
@property (nonatomic, readonly) UILabel         *titleLabel;

@end
