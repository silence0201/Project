//
//  V2Topic.h
//  V2EX
//
//  Created by Silence on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2BaseEntity.h"
#import <UIKit/UIKit.h>

typedef NS_ENUM (NSInteger, V2TopicState) {
    V2TopicStateUnreadWithReply      = 1 << 0,
    V2TopicStateUnreadWithoutReply   = 1 << 1,
    V2TopicStateReadWithoutReply     = 1 << 2,
    V2TopicStateReadWithReply        = 1 << 3,
    V2TopicStateReadWithNewReply     = 1 << 4,
    V2TopicStateRepliedWithNewReply  = 1 << 5,
    
};

typedef NS_ENUM (NSInteger, V2ContentType) {
    V2ContentTypeString,
    V2ContentTypeImage,
};

@class V2Node,V2Member,SIQuote ;
@interface V2Topic : V2BaseEntity

@property (nonatomic,copy) NSString *topicId;
@property (nonatomic,copy) NSString *topicTitle;
@property (nonatomic,copy) NSString *topicReplyCount;
@property (nonatomic,copy) NSString *topicUrl;
@property (nonatomic,copy) NSString *topicContent;
@property (nonatomic,copy) NSString *topicContentRendered;
@property (nonatomic,copy) NSNumber *topicCreated;
@property (nonatomic,copy) NSString *topicModified;
@property (nonatomic,copy) NSString *topicTouched;
@property (nonatomic,strong) V2Member *topicCreator;
@property (nonatomic,strong) V2Node   *topicNode;

@property (nonatomic,copy) NSString *topicCreatedDescription;
@property (nonatomic,strong) NSArray            *quoteArray;
@property (nonatomic,copy  ) NSAttributedString *attributedString;
@property (nonatomic,strong) NSArray            *contentArray;
@property (nonatomic,strong) NSArray            *imageURLs;
@property (nonatomic,assign) V2TopicState  state;

@property (nonatomic,assign) CGFloat cellHeight;
@property (nonatomic,assign) CGFloat titleHeight;

+ (NSArray<V2Topic *> *)getTopicListFromResponseObject:(id)responseObject ;

@end



@interface V2ContentBase : V2BaseEntity

@property (nonatomic, assign) V2ContentType contentType;

@end

@interface V2ContentString : V2ContentBase

@property (nonatomic, copy) NSAttributedString *attributedString;
@property (nonatomic, strong) NSArray *quoteArray;

@end

@interface V2ContentImage : V2ContentBase

@property (nonatomic, strong)  SIQuote *imageQuote;

@end

