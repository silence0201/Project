//
//  V2MenuView.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedIndexBlock)(NSInteger);

@interface V2MenuView : UIView

@property (nonatomic,copy) SelectedIndexBlock selectedAction ;

@property (nonatomic,strong) UIImage *blurredImage ;

- (void)setOffsetProgress:(CGFloat)progress;
- (void)selectIndex:(NSUInteger)index;

@end
