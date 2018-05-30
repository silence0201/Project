//
//  UIImage+Tint.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)

@property (nonatomic,readonly) UIImage *imageForCurrentTheme;

- (UIImage *)imageWithTintColor:(UIColor *)tintColor;
- (CGSize)fitWidth:(CGFloat)fitWidth;


@property (nonatomic, assign) BOOL cached;

- (UIImage *)imageWithCornerRadius:(CGFloat)cornerRadius;
@end
