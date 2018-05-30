//
//  V2NodesViewCell.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/22.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2NodesViewCell : UITableViewCell

@property (nonatomic, strong) NSArray *nodesArray;
@property (nonatomic, weak) UINavigationController *navi;

+ (CGFloat)getCellHeightWithNodesArray:(NSArray *)nodes;

@end
