//
//  V2MenuSectionCell.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2MenuSectionCell : UITableViewCell

@property (nonatomic,copy) NSString *imageName ;
@property (nonatomic,copy) NSString *title ;

@property (nonatomic,assign) BOOL cellHighlighted ;

@property (nonatomic,copy) NSString *badge ;

+ (CGFloat)getCellHeight;

@end
