//
//  V2ProfileCell.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/21.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, V2ProfileCellType) {
    V2ProfileCellTypeTopic,
    V2ProfileCellTypeReply,
    V2ProfileCellTypeTwitter,
    V2ProfileCellTypeLocation,
    V2ProfileCellTypeWebsite
};

static NSString *const kProfileType = @"profileType";
static NSString *const kProfileValue = @"profileValue";

@interface V2ProfileCell : UITableViewCell

@property (nonatomic, assign) V2ProfileCellType type;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) BOOL isTop;
@property (nonatomic, assign) BOOL isBottom;

+ (CGFloat)getCellHeight;


@end
