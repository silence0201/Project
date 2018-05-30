//
//  V2ActionCellView.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/24.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2ActionCellView.h"
#import "V2ActionItemView.h"

@interface V2ActionCellView ()

@property (nonatomic, strong) NSArray *itemArray;

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *imageNames;

@end

@implementation V2ActionCellView

- (instancetype)initWithTitles:(NSArray *)titles imageNames:(NSArray *)imageNames {
    if (self = [super initWithFrame:(CGRect){0, 0, kScreenWidth, kActionItemHeight}]) {
        if (titles.count) {
            self.height = kActionItemHeightTitle;
        } else {
            self.height = kActionItemHeight;
        }
        CGFloat startX = 15;
        CGFloat space = (kScreenWidth - 2 * startX - kActionItemWidth * 4) / 5;
        NSMutableArray *itemArray = [NSMutableArray new];
        for (NSInteger i = 0; i < imageNames.count; i ++) {
            NSString *title;
            if (i < titles.count) {
                title = titles[i];
            }
            V2ActionItemView *itemView = [[V2ActionItemView alloc] initWithTitle:title imageName:imageNames[i]];
            [self addSubview:itemView];
            [itemArray addObject:itemView];
            itemView.left = startX + space + (space + kActionItemWidth) * i;
        }
        self.itemArray = itemArray;
    }
    return self;
}


- (void)setButtonHandler:(void (^)(void))block forIndex:(NSInteger)index {
    if (index >= self.itemArray.count || !block) {
        return;
    }
    V2ActionItemView *itemView = self.itemArray[index];
    [itemView setActionBlock:^(UIButton *button, UILabel *item) {
        if (self.actionSheet) {
            [self.actionSheet hide:YES];
        }
        block();
    }];
    
}



@end
