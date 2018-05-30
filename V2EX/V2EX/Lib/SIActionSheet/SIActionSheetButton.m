//
//  SIActionSheetButton.m
//  V2EX
//
//  Created by 杨晴贺 on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "SIActionSheetButton.h"
#import <YYCategories/YYCategories.h>

@implementation SIActionSheetButton{
    UIView *_bottomLineView ;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        _type = SIActionSheetButtonTypeNormal ;
        self.layer.borderColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1].CGColor ;
        self.layer.borderWidth = .5f ;
        self.backgroundColor = [UIColor whiteColor] ;
        [self setTitleColor:kFontColorBlackMid forState:UIControlStateNormal] ;        
        UIImage *btnImage = [UIImage imageWithColor:RGB(0x000000, 0.1) size:CGSizeMake(kScreenWidth, 44.0f)] ;
        
        if (btnImage && btnImage.size.width > 0) {
            [self setBackgroundImage:btnImage forState:UIControlStateReserved];
            [self setBackgroundImage:btnImage forState:UIControlStateSelected];
            [self setBackgroundImage:btnImage forState:UIControlStateHighlighted];
        }
        
        _bottomLineView = [[UIView alloc] initWithFrame:(CGRect){0, self.height, self.width, 0.5}];
        _bottomLineView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.07];
        [self addSubview:_bottomLineView];
    }
    return self ;
}

- (void)setButtonBackgroundColor:(UIColor *)buttonBackgroundColor {
    _buttonBackgroundColor = buttonBackgroundColor;
    UIImage *btnImage = [UIImage imageWithColor:buttonBackgroundColor size:CGSizeMake(kScreenWidth, 44.0f)] ;
    
    if (btnImage && btnImage.size.width > 0) {
        [self setBackgroundImage:btnImage forState:UIControlStateReserved];
        [self setBackgroundImage:btnImage forState:UIControlStateSelected];
        [self setBackgroundImage:btnImage forState:UIControlStateHighlighted];
    }
}

- (void)setButtonBottomLineColor:(UIColor *)buttonBottomLineColor {
    _buttonBottomLineColor = buttonBottomLineColor;
    _bottomLineView.backgroundColor = self.buttonBottomLineColor;
}

- (void)setButtonBorderColor:(UIColor *)buttonBorderColor {
    _buttonBorderColor = buttonBorderColor;
    self.layer.borderColor = self.buttonBorderColor.CGColor;
}

- (void)setType:(SIActionSheetButtonType)type {
    _type = type;
    if (type == SIActionSheetButtonTypeRed) {
        self.backgroundColor = RGB(0xf86a5b, 1.0);
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.buttonBackgroundColor = RGB(0xe95545, 1.0);
        self.buttonBottomLineColor = RGB(0xe95545, 1.0);
        self.buttonBorderColor = RGB(0xe95545, 1.0);
    } else {
        self.backgroundColor = RGB(0x000000, .1);
        [self setTitleColor:RGB(0x6e6e6e, 1.0) forState:UIControlStateNormal];
        self.buttonBackgroundColor = RGB(0x000000, .1);
        self.buttonBottomLineColor = RGB(0x000000, .1);
        self.buttonBorderColor = RGB(0x000000, .1);
    }
}

@end
