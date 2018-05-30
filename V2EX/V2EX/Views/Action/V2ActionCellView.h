//
//  V2ActionCellView.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/24.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "SIActionSheet.h"

@interface V2ActionCellView : UIView

@property (nonatomic, weak) SIActionSheet *actionSheet;

- (instancetype)initWithTitles:(NSArray *)titles imageNames:(NSArray *)imageNames;

- (void)setButtonHandler:(void (^)(void))block forIndex:(NSInteger)index;

@end
