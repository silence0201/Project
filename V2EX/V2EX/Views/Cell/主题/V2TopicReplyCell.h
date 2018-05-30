//
//  V2TopicReplyCell.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/24.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2TopicReplyCell : UITableViewCell

@property (nonatomic, strong) V2Reply *model;
@property (nonatomic, strong) V2Reply *selectedReplyModel;

@property (nonatomic, assign) UINavigationController *navi;
@property (nonatomic, assign) NSMutableArray<V2Reply *> *replyList;

@property (nonatomic, copy) void (^longPressedBlock)();
@property (nonatomic, copy) void (^reloadCellBlock)();

+ (CGFloat)getCellHeightWithReply:(V2Reply *)model;

@end
