//
//  V2SettingCell.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/22.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2SettingCell : UITableViewCell

@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign, getter = isTop) BOOL top;
@property (nonatomic, assign, getter = isBottom) BOOL bottom;

@end
