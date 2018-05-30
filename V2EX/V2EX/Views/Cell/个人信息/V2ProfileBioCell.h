//
//  V2ProfileBioCell.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/21.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2ProfileBioCell : UITableViewCell

@property (nonatomic, copy) NSString *bioString;

+ (CGFloat)getCellHeightWithBioString:(NSString *)bioString;

@end
