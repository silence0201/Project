//
//  V2QuickActionManager.m
//  V2EX
//
//  Created by 杨晴贺 on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//


NSString * V2CheckInQuickAction = @"com.silence.v2ex.checkin";
NSString * V2NotificationQuickAction = @"com.silence.v2ex.notification";

@implementation V2QuickActionManager

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)manager {
    static V2QuickActionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[V2QuickActionManager alloc] init];
    });
    return manager;
}

- (void)updateAction{
    NSArray <UIApplicationShortcutItem *> *existingShortcutItems = [[UIApplication sharedApplication] shortcutItems];
    if (existingShortcutItems.count != 1) {
        UIApplicationShortcutItem *checkInItem = [self createCheckInItem];
        [[UIApplication sharedApplication] setShortcutItems: @[checkInItem]];
    }
    [self updateCheckInItem];
}

- (void)updateCheckInItem{
    NSArray <UIApplicationShortcutItem *> *existingShortcutItems = [[UIApplication sharedApplication] shortcutItems];
    UIApplicationShortcutItem *anExistingShortcutItem;
    for (UIApplicationShortcutItem *item in existingShortcutItems) {
        if ([item.type isEqualToString:V2CheckInQuickAction]) {
            anExistingShortcutItem = item;
        }
    }
    if (anExistingShortcutItem) {
        NSUInteger anIndex = [existingShortcutItems indexOfObject:anExistingShortcutItem];
        NSMutableArray <UIApplicationShortcutItem *> *updatedShortcutItems = [existingShortcutItems mutableCopy];
        UIMutableApplicationShortcutItem *aMutableShortcutItem = [anExistingShortcutItem mutableCopy];
        aMutableShortcutItem.localizedTitle = [NSString stringWithFormat:@"签到"];
        if ([V2CheckInManager manager].checkInCount > 0) {
            aMutableShortcutItem.localizedSubtitle = [NSString stringWithFormat:@"已连续登录 %zd 天", [V2CheckInManager manager].checkInCount];
        } else {
            aMutableShortcutItem.localizedSubtitle = nil;
        }
        [updatedShortcutItems replaceObjectAtIndex: anIndex withObject: aMutableShortcutItem];
        [[UIApplication sharedApplication] setShortcutItems: updatedShortcutItems];
    }
}

- (UIApplicationShortcutItem *)createCheckInItem{
    UIApplicationShortcutIcon *checkInIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"quick_checkin"];
    UIMutableApplicationShortcutItem *checkInItem = [[UIMutableApplicationShortcutItem alloc] initWithType:V2CheckInQuickAction localizedTitle:@"签到" localizedSubtitle:nil icon:checkInIcon userInfo:nil];
    if ([V2CheckInManager manager].checkInCount > 0) {
        checkInItem.localizedSubtitle = [NSString stringWithFormat:@"已连续登录 %zd 天", [V2CheckInManager manager].checkInCount];
    }
    return checkInItem;
}

#pragma mark - Notifications
- (void)didReceiveEnterBackgroundNotification {
    if (kDeviceOSVersion > 9.0) {
        [self updateAction];
    }
}


@end
