//
//  V2TopicBodyCell.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/24.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2TopicBodyCell : UITableViewCell

@property (nonatomic, strong) V2Topic *model;
@property (nonatomic, assign) UINavigationController *navi;

@property (nonatomic, copy) void (^reloadCellBlock)();

+ (CGFloat)getCellHeightWithTopic:(V2Topic *)model;

@end
