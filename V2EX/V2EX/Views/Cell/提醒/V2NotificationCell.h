//
//  V2NotificationCell.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/23.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2NotificationCell : UITableViewCell

@property (nonatomic, strong) V2Notification *model;
@property (nonatomic, weak) UINavigationController *navi;

@property (nonatomic, assign, getter = isTop) BOOL top;

+ (CGFloat)getCellHeightWithNotification:(V2Notification *)model;

@end
