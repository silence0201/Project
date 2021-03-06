//
//  V2Notification.h
//  V2EX
//
//  Created by 杨晴贺 on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//


@interface V2Notification : V2BaseEntity

@property (nonatomic, copy) NSString *notificationDescriptionBefore;
@property (nonatomic, copy) NSString *notificationDescriptionAfter;
@property (nonatomic, copy) NSString *notificationContent;
@property (nonatomic, copy) NSString *notificationCreatedDescription;
@property (nonatomic, copy) NSString *notificationId;
@property (nonatomic, strong) V2Topic  *notificationTopic;
@property (nonatomic, strong) V2Member *notificationMember;

@property (nonatomic, copy) NSAttributedString *notificationTopAttributedString;
@property (nonatomic, copy) NSAttributedString *notificationDescriptionAttributedString;

+ (NSArray<V2Notification *> *)getNotificationFromResponseObject:(id)responseObject;

@end


