//
//  V2TopicCell.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/21.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface V2TopicCell : UITableViewCell

@property (nonatomic,strong) V2Topic *model ;
@property (nonatomic,assign) BOOL isTop ;

- (void)updateStatus;

+ (CGFloat)getCellHeightWithTopic:(V2Topic *)model;
+ (CGFloat)heightWithTopic:(V2Topic *)model;


@end
