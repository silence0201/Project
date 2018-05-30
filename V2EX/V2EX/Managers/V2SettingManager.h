//
//  V2SettingManager.h
//  V2EX
//
//  Created by 杨晴贺 on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2BaseManager.h"

typedef NS_ENUM(NSInteger, V2Theme) {
    V2ThemeDefault,
    V2ThemeNight,
};

@interface V2SettingManager : V2BaseManager

#pragma mark - Index

@property (nonatomic, assign) NSUInteger selectedSectionIndex ;
@property (nonatomic, assign) NSUInteger categoriesSelectedSectionIndex;
@property (nonatomic, assign) NSUInteger favoriteSelectedSectionIndex;

#pragma mark - Theme

@property (nonatomic, assign) V2Theme theme;
@property (nonatomic, assign) BOOL themeAutoChange;

@property (nonatomic, copy) UIColor *navigationBarColor;
@property (nonatomic, copy) UIColor *navigationBarLineColor;
@property (nonatomic, copy) UIColor *navigationBarTintColor;

@property (nonatomic, copy) UIColor *backgroundColorWhite;
@property (nonatomic, copy) UIColor *backgroundColorWhiteDark;

@property (nonatomic, copy) UIColor *lineColorBlackDark;
@property (nonatomic, copy) UIColor *lineColorBlackLight;

@property (nonatomic, copy) UIColor *fontColorBlackDark;
@property (nonatomic, copy) UIColor *fontColorBlackMid;
@property (nonatomic, copy) UIColor *fontColorBlackLight;
@property (nonatomic, copy) UIColor *fontColorBlackBlue;

@property (nonatomic, copy) UIColor *colorBlue;
@property (nonatomic, copy) UIColor *cellHighlightedColor;
@property (nonatomic, copy) UIColor *menuCellHighlightedColor;

@property (nonatomic, assign) CGFloat imageViewAlphaForCurrentTheme;

#pragma mark - Notification

@property (nonatomic, assign) BOOL checkInNotiticationOn;
@property (nonatomic, assign) BOOL newNotificationOn;

#pragma mark - NavigationBar

@property (nonatomic, assign) BOOL navigationBarAutoHidden;

#pragma mark - Traffic

@property (nonatomic, assign) BOOL trafficSaveModeOn;
@property (nonatomic, assign) BOOL trafficSaveModeOnSetting;

@end
