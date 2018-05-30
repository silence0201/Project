//
//  SIEmptyTableView.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "SIEmptyTableView.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

@interface SIEmptyTableView ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>



@end

@implementation SIEmptyTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if(self = [super initWithFrame:frame style:style]){
        self.emptyDataSetSource = self ;
        self.emptyDataSetDelegate = self ;
        _title = @"正在刷新" ;
        _buttonTitle = @"点击重试" ;
        
    }
    return self ;
}

- (void)setLoading:(BOOL)loading{
    if (self.isLoading == loading) {
        return;
    }
    _loading = loading;
    [self reloadEmptyDataSet];
}


#pragma mark - DZNEmptyDataSetSource Methods
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = self.title;
    UIFont *font = [UIFont systemFontOfSize:16];
    UIColor *textColor = [UIColor colorWithRGB:0xa4a4a4];
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView{
    if (self.isLoading) {
        return [UIImage imageNamed:@"loading_imgBlue"] ;
    }else {
        return [UIImage imageNamed:@"placeholder_empty"] ;
    }
}

- (CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D: CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0) ];
    animation.duration = 0.25;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    
    return animation;
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state{
    NSString *text = self.buttonTitle;
    UIFont *font = [UIFont systemFontOfSize:16.0];
    UIColor *textColor = [UIColor colorWithRGB:(state == UIControlStateNormal) ? 0xfc6246 : 0xfdbbb2];
    
    NSMutableDictionary *attributes = [NSMutableDictionary new];
    if (font) [attributes setObject:font forKey:NSFontAttributeName];
    if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView{
    return [UIColor colorWithRGB:0xf2f2f2] ;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView{
    return 18.0f ;
}

#pragma mark - DZNEmptyDataSetDelegate Methods
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView{
    return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView{
    return YES;
}

- (BOOL)emptyDataSetShouldAnimateImageView:(UIScrollView *)scrollView{
    return self.isLoading;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view{
    self.title = @"正在刷新" ;
    self.loading = YES;
    if (self.emptyClickAction) {
        self.emptyClickAction() ;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.title = @"刷新失败" ;
        self.loading = NO;
    });
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button{
    self.title = @"正在刷新" ;
    self.loading = YES;
    if (self.emptyClickAction) {
        self.emptyClickAction() ;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.loading = NO;
        self.title = @"刷新失败" ;
    });
}




@end
