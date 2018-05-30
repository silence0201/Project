//
//  V2MemberReplyCell.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/23.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2MemberReplyCell : UITableViewCell

@property (nonatomic, strong) V2MemberReply *model;

@property (nonatomic, assign, getter = isTop) BOOL top;

+ (CGFloat)getCellHeightWithMemberReply:(V2MemberReply *)model;

@end
