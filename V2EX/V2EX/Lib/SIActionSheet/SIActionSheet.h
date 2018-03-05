//
//  SIActionSheet.h
//  V2EX
//
//  Created by Silence on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SIActionSheetButton ;
@interface SIActionSheet : UIView

@property (nonatomic, copy) UIColor *titleTextColor;
@property (nonatomic, copy) UIColor *deviderLineColor;
@property (nonatomic, copy) void (^endAnimationBlock)();

@property (nonatomic, strong) UIView *showInView;

+ (BOOL)isActionSheetShowing;

- (instancetype)initWithTitles:(NSArray *)titles customViews:(NSArray *)customViews buttonTitles:(NSString *)buttonTitles, ...;


- (void)setButtonHandler:(void (^)(void))block forIndex:(NSInteger)index;
- (void)configureButtonWithBlock:(void (^)(SIActionSheetButton *button))block forIndex:(NSInteger)index;

- (void)show:(BOOL)animated;
- (void)hide:(BOOL)animated;

@end
