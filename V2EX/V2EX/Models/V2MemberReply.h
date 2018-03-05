//
//  V2MemberReply.h
//  V2EX
//
//  Created by Silence on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2BaseEntity.h"

@class V2Topic ;
@interface V2MemberReply : V2BaseEntity

@property (nonatomic, copy  ) NSString           *memberReplyContent;
@property (nonatomic, copy  ) NSString           *memberReplyCreatedDescription;

@property (nonatomic, copy  ) NSAttributedString *memberReplyTopAttributedString;
@property (nonatomic, copy  ) NSAttributedString *memberReplyContentAttributedString;

@property (nonatomic, strong) V2Topic       *memberReplyTopic;

+ (NSArray<V2MemberReply *> *)getMemberReplyListFromResponseObject:(id)responseObject;

@end

