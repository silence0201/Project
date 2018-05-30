//
//  UIImage+Tint.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "UIImage+Tint.h"

@implementation UIImage (Tint)

- (UIImage *)imageForCurrentTheme {
    UIImage *image = self;
    if (kCurrentTheme == V2ThemeNight) {
        image = [image imageWithTintColor:[UIColor whiteColor]];
    }
    return image;
}

- (UIImage *)imageWithTintColor:(UIColor *)tintColor;{
    if (tintColor) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, self.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
        CGContextClipToMask(context, rect, self.CGImage);
        [tintColor setFill];
        CGContextFillRect(context, rect);
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    return self;
    
}

- (CGSize)fitWidth:(CGFloat)fitWidth {
    CGFloat height = self.size.height;
    CGFloat width = self.size.width;
    if (width > fitWidth) {
        height *= fitWidth/width;
        width = fitWidth;
    }
    return CGSizeMake(width, height);
}

- (BOOL)cached {
    return [objc_getAssociatedObject(self, @selector(cached)) boolValue];
}

- (void)setCached:(BOOL)cached {
    objc_setAssociatedObject(self, @selector(cached), @(cached), OBJC_ASSOCIATION_ASSIGN);
}

- (UIImage *)imageWithCornerRadius:(CGFloat)cornerRadius {
    
    UIImage* imageNew;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    
    const CGRect RECT = CGRectMake(0, 0, self.size.width, self.size.height);
    [[UIBezierPath bezierPathWithRoundedRect:RECT cornerRadius:cornerRadius] addClip];
    [self drawInRect:RECT];
    imageNew = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageNew;
}

@end
