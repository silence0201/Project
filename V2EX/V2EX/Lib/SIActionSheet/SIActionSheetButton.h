//
//  SIActionSheetButton.h
//  V2EX
//
//  Created by Silence on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, SIActionSheetButtonType) {
    SIActionSheetButtonTypeRed,
    SIActionSheetButtonTypeNormal
};

@interface SIActionSheetButton : UIButton

@property (nonatomic,strong) UIColor *buttonBottomLineColor;
@property (nonatomic,strong) UIColor *buttonBackgroundColor;
@property (nonatomic,strong) UIColor *buttonBorderColor;

@property (nonatomic,assign) SIActionSheetButtonType type;

@end
