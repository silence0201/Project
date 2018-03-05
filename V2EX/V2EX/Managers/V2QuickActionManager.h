//
//  V2QuickActionManager.h
//  V2EX
//
//  Created by Silence on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2BaseManager.h"


FOUNDATION_EXPORT NSString * V2CheckInQuickAction;
FOUNDATION_EXPORT NSString * V2NotificationQuickAction;

@interface V2QuickActionManager : V2BaseManager

- (void)updateAction;

@end
