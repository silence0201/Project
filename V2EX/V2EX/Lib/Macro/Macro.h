//
//  Color.h
//  V2EX
//
//  Created by Silence on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#ifndef Macro_h
#define Macro_h

#import "V2SettingManager.h"

#define RGB(c,a)    [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

#define kSetting                   [V2SettingManager manager]

#define kNavigationBarTintColor    kSetting.navigationBarTintColor
#define kNavigationBarColor        kSetting.navigationBarColor
#define kNavigationBarLineColor    kSetting.navigationBarLineColor

#define kBackgroundColorWhite      kSetting.backgroundColorWhite
#define kBackgroundColorWhiteDark  kSetting.backgroundColorWhiteDark

#define kLineColorBlackDark        kSetting.lineColorBlackDark
#define kLineColorBlackLight       kSetting.lineColorBlackLight

#define kFontColorBlackDark        kSetting.fontColorBlackDark
#define kFontColorBlackMid         kSetting.fontColorBlackMid
#define kFontColorBlackLight       kSetting.fontColorBlackLight
#define kFontColorBlackBlue        kSetting.fontColorBlackBlue

#define kColorBlue                 kSetting.colorBlue
#define kCellHighlightedColor      kSetting.cellHighlightedColor
#define kMenuCellHighlightedColor  kSetting.menuCellHighlightedColor

#define kCurrentTheme              kSetting.theme

#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)

#define kDeviceOSVersion ([[[UIDevice currentDevice] systemVersion] floatValue])

#define AppDelegate ((V2AppDelegate *)[UIApplication sharedApplication].delegate)
#define WeakSelf __weak typeof(self) weakSelf = self;

#endif /* Color_h */
