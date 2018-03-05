//
//  V2Reply.h
//  V2EX
//
//  Created by Silence on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2BaseEntity.h"

@class V2Member ;
@interface V2Reply : V2BaseEntity

@property (nonatomic, copy  ) NSString *replyId;
@property (nonatomic, copy  ) NSString *replyThanksCount;
@property (nonatomic, copy  ) NSString *replyModified;
@property (nonatomic, strong) NSNumber *replyCreated;
@property (nonatomic, copy  ) NSString *replyContent;
@property (nonatomic, copy  ) NSString *replyContentRendered;
@property (nonatomic, strong) V2Member *replyCreator;

@property (nonatomic, strong) NSArray            *quoteArray;
@property (nonatomic, copy  ) NSAttributedString *attributedString;
@property (nonatomic, strong) NSArray            *contentArray;
@property (nonatomic, strong) NSArray            *imageURLs;

@end

@interface V2ReplyList : V2BaseEntity

@property (nonatomic, strong) NSArray *list;
- (instancetype)initWithArray:(NSArray *)array;

@end
