//
//  V2Topic.m
//  V2EX
//
//  Created by 杨晴贺 on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2Helper.h"
#import "NSString+SIMention.h"
#import "SIQuote.h"
#import <SIHTMLParser/HTMLParser.h>
#import <RegexKitLite/RegexKitLite.h>
#import <YYCategories/NSString+YYAdd.h>

@implementation V2Topic

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{@"topicId"  : @"id",
             @"topicTitle"  : @"title",
             @"topicReplyCount"  : @"replies",
             @"topicUrl": @"url",
             @"topicContent"  : @"content",
             @"topicContentRendered"  : @"content_rendered",
             @"topicCreated"  : @"created",
             @"topicModified": @"last_modified",
             @"topicTouched"  : @"last_touched",
             @"topicNode"  : @"node",
             @"topicCreator": @"member",
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic{
    self.state = [[V2TopicStateManager manager] getTopicStateWithTopicModel:self];
    self.cellHeight = [V2Topic heightWithTopicModel:self];
    self.topicContent = [self.topicContent stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
    self.topicContent = [self.topicContent stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    self.topicContent = [self.topicContent stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
    while ([self.topicContent rangeOfString:@"\n\n"].location != NSNotFound) {
        self.topicContent = [self.topicContent stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
    }
    self.state  = [[V2TopicStateManager manager] getTopicStateWithTopicModel:self];
    if (self.topicCreated) {
        self.topicCreatedDescription = [V2Helper timeRemainDescriptionWithDateSP:self.topicCreated] ;
    }
    
    self.quoteArray = [self.topicContentRendered quoteArray] ;
    
    NSString *mentionString = self.topicContent;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.topicContent];
    [attributedString addAttribute:NSForegroundColorAttributeName value:kFontColorBlackDark range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, attributedString.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8.0;
    [attributedString addAttributes:@{
                                      NSParagraphStyleAttributeName: style,
                                      } range:NSMakeRange(0, attributedString.length)];
    NSMutableArray *imageURLs = [[NSMutableArray alloc] init];
    
    for (SIQuote *quote in self.quoteArray) {
        NSRange range = [mentionString rangeOfString:quote.string];
        if (range.location != NSNotFound) {
            mentionString = [mentionString stringByReplacingOccurrencesOfString:quote.string withString:[self spaceWithLength:range.length]];
            quote.range = range;
            if (quote.type == SIQuoteTypeUser) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:(id)RGB(0x778087, 0.8) range:NSMakeRange(range.location - 1, 1)];
            }
        } else {
            NSString *string = [quote.string stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSRange range = [mentionString rangeOfString:string];
            if (range.location != NSNotFound) {
                mentionString = [mentionString stringByReplacingOccurrencesOfString:quote.string withString:[self spaceWithLength:range.length]];
                quote.range = range;
            } else {
                quote.range = NSMakeRange(0, 0);
            }
        }
        if (quote.type == SIQuoteTypeImage) {
            [imageURLs addObject:quote.identifier];
        }
    }
    
    self.imageURLs = imageURLs;
    self.attributedString = attributedString;
    
    if (!kSetting.trafficSaveModeOn) {
        NSMutableArray *contentArray = [[NSMutableArray alloc] init];
        __block NSUInteger lastStringIndex = 0;
        __block NSUInteger lastImageQuoteIndex = 0;
        [self.quoteArray enumerateObjectsUsingBlock:^(SIQuote *quote, NSUInteger idx, BOOL *stop) {
            
            if (quote.type == SIQuoteTypeImage) {
                
                if (quote.range.location > lastStringIndex) {
                    
                    V2ContentString *stringModel = [[V2ContentString alloc] init];
                    
                    NSAttributedString *subString = [attributedString attributedSubstringFromRange:(NSRange){lastStringIndex, quote.range.location - lastStringIndex}];
                    NSAttributedString *firstString = [subString attributedSubstringFromRange:(NSRange){0, 1}];
                    NSInteger stringOffset = 0;
                    if ([firstString.string isEqualToString:@"\n"]) {
                        stringOffset = 1;
                        subString = [attributedString attributedSubstringFromRange:(NSRange){lastStringIndex + stringOffset, quote.range.location - lastStringIndex - stringOffset}];
                    }
                    stringModel.attributedString = subString;
                    
                    NSMutableArray *quotes = [[NSMutableArray alloc] init];
                    for (NSInteger i = lastImageQuoteIndex; i < idx; i ++) {
                        SIQuote *otherQuote = self.quoteArray[i];
                        otherQuote.range = (NSMakeRange(otherQuote.range.location - lastStringIndex, otherQuote.range.length));
                        [quotes addObject:self.quoteArray[i]];
                    }
                    if (quotes.count > 0) {
                        stringModel.quoteArray = quotes;
                    }
                    
                    [contentArray addObject:stringModel];
                    
                }
                
                V2ContentImage *imageModel = [[V2ContentImage alloc] init];
                imageModel.imageQuote = quote;
                [contentArray addObject:imageModel];
                lastImageQuoteIndex = idx + 1;
                lastStringIndex = quote.range.location + quote.range.length;
            }
            
        }];
        
        if (lastStringIndex < attributedString.length) {
            
            V2ContentString *stringModel = [[V2ContentString alloc] init];
            
            NSAttributedString *subString = [attributedString attributedSubstringFromRange:(NSRange){lastStringIndex, attributedString.length - lastStringIndex}];
            NSAttributedString *firstString = [subString attributedSubstringFromRange:(NSRange){0, 1}];
            NSInteger stringOffset = 0;
            if ([firstString.string isEqualToString:@"\n"]) {
                stringOffset = 1;
                subString = [attributedString attributedSubstringFromRange:(NSRange){lastStringIndex + stringOffset, attributedString.length - lastStringIndex - stringOffset}];
            }
            stringModel.attributedString = subString;
            
            NSMutableArray *quotes = [[NSMutableArray alloc] init];
            for (NSInteger i = lastImageQuoteIndex; i < self.quoteArray.count; i ++) {
                SIQuote *otherQuote = self.quoteArray[i];
                NSInteger location = otherQuote.range.location - lastStringIndex - stringOffset;
                if (location >= 0) {
                    otherQuote.range = NSMakeRange(location, otherQuote.range.length);
                } else {
                    otherQuote.range = NSMakeRange(0, 0);
                }
                [quotes addObject:self.quoteArray[i]];
            }
            if (quotes.count > 0) {
                stringModel.quoteArray = quotes;
            }
            
            [contentArray addObject:stringModel];
            
        }
        
        self.contentArray = contentArray;
    }
    return YES ;
}

- (NSString *)spaceWithLength:(NSUInteger)length {
    NSString *spaceString = @"";
    while (spaceString.length < length) {
        spaceString = [spaceString stringByAppendingString:@" "];
    }
    return spaceString;
}

/// 通过html
+ (NSArray<V2Topic *> *)getTopicListFromResponseObject:(id)responseObject {
    
    NSMutableArray *topicArray = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
            return nil;
        }
        HTMLNode *bodyNode = [parser body];
        NSArray *cellNodes = [bodyNode findChildrenTag:@"div"];
        
        for (HTMLNode *cellNode in cellNodes) {
            if ([[cellNode getAttributeNamed:@"class"] isEqualToString:@"cell item"] || [[cellNode getAttributeNamed:@"class"] hasPrefix:@"cell"]) {
                V2Topic *model = [[V2Topic alloc] init];
                model.topicCreator = [[V2Member alloc] init];
                model.topicNode = [[V2Node alloc] init];
                
                NSArray *tdNodes = [cellNode findChildrenTag:@"td"];
                
                NSInteger index = 0;
                for (HTMLNode *tdNode in tdNodes) {
                    NSString *content = tdNode.rawContents;
                    
                    if ([content rangeOfString:@"class=\"avatar\""].location != NSNotFound) {
                        
                        HTMLNode *userIdNode = [tdNode findChildTag:@"a"];
                        if (userIdNode) {
                            NSString *idUrlString = [userIdNode getAttributeNamed:@"href"];
                            model.topicCreator.memberName = [[idUrlString componentsSeparatedByString:@"/"] lastObject];
                        }
                        
                        HTMLNode *avatarNode = [tdNode findChildTag:@"img"];
                        if (avatarNode) {
                            NSString *avatarString = [avatarNode getAttributeNamed:@"src"];
                            if ([avatarString hasPrefix:@"//"]) {
                                avatarString = [@"http:" stringByAppendingString:avatarString];
                            }
                            model.topicCreator.memberAvatarNormal = avatarString;
                        }
                    }
                    if ([content rangeOfString:@"class=\"item_title\""].location != NSNotFound) {
                        
                        NSArray *aNodes = [tdNode findChildrenTag:@"a"];
                        
                        for (HTMLNode *aNode in aNodes) {
                            if ([[aNode getAttributeNamed:@"class"] isEqualToString:@"node"]) {
                                NSString *nodeUrlString = [aNode getAttributeNamed:@"href"];
                                model.topicNode.nodeName = [[nodeUrlString componentsSeparatedByString:@"/"] lastObject];
                                model.topicNode.nodeTitle = aNode.allContents;
                                
                            } else {
                                if ([aNode.rawContents rangeOfString:@"reply"].location != NSNotFound) {
                                    model.topicTitle = aNode.allContents;
                                    
                                    NSString *topicIdString = [aNode getAttributeNamed:@"href"];
                                    NSArray *subArray = [topicIdString componentsSeparatedByString:@"#"];
                                    model.topicId = [(NSString *)subArray.firstObject stringByReplacingOccurrencesOfString:@"/t/" withString:@""];
                                    model.topicReplyCount = [(NSString *)subArray.lastObject stringByReplacingOccurrencesOfString:@"reply" withString:@""];
                                }
                            }
                        }
                        
                        NSArray *spanNodes = [tdNode findChildrenTag:@"span"];
                        for (HTMLNode *spanNode in spanNodes) {
                            if ([spanNode.rawContents rangeOfString:@"href"].location == NSNotFound) {
                                model.topicCreatedDescription = spanNode.allContents;
                            }
                            if ([spanNode.rawContents rangeOfString:@"最后回复"].location != NSNotFound || [spanNode.rawContents rangeOfString:@"前"].location != NSNotFound) {
                                
                                NSString *contentString = spanNode.allContents;
                                NSArray *components = [contentString componentsSeparatedByString:@"  •  "];
                                NSString *dateString;
                                
                                if (components.count > 2) {
                                    dateString = components[2];
                                } else {
                                    dateString = [contentString stringByReplacingOccurrencesOfRegex:@"  •  (.*?)$" withString:@""];
                                }
                                
                                NSArray *stringArray = [dateString componentsSeparatedByString:@" "];
                                if (stringArray.count > 1) {
                                    NSString *unitString = @"";
                                    NSString *subString = [(NSString *)stringArray[1] substringToIndex:1];
                                    if ([subString isEqualToString:@"分"]) {
                                        unitString = @"分钟前";
                                    }
                                    if ([subString isEqualToString:@"小"]) {
                                        unitString = @"小时前";
                                    }
                                    if ([subString isEqualToString:@"天"]) {
                                        unitString = @"天前";
                                    }
                                    dateString = [NSString stringWithFormat:@"%@%@", stringArray[0], unitString];
                                } else {
                                    dateString = @"刚刚";
                                }
                                model.topicCreatedDescription = dateString;
                            }
                        }
                        
                    }
                    index ++;
                }
                model.state = [[V2TopicStateManager manager] getTopicStateWithTopicModel:model];
                model.cellHeight = [self heightWithTopicModel:model];
                if(model.topicTitle.length > 0){
                    [topicArray addObject:model];
                }
            }
        }
        
    }
    return topicArray;
}

+ (CGFloat)heightWithTopicModel:(V2Topic *)model {
    CGFloat titleHeight = [model.topicTitle heightForFont:[UIFont systemFontOfSize:17.0] width:kScreenWidth - 56] ;
    CGFloat bottomHeight = [model.topicNode.nodeName heightForFont:[UIFont systemFontOfSize:17.0] width:CGFLOAT_MAX]+1 ;
    CGFloat cellHeight = 8 + 13 * 2 + titleHeight + bottomHeight;
    model.cellHeight = cellHeight;
    model.titleHeight = titleHeight;
    return cellHeight;
}

@end


@implementation V2ContentBase

@end


@implementation V2ContentString

- (instancetype)init {
    if (self = [super init]) {
        self.contentType = V2ContentTypeString;
    }
    return self;
}

@end


@implementation V2ContentImage

- (instancetype)init {
    if (self = [super init]) {
        self.contentType = V2ContentTypeImage;
    }
    return self;
    
}

@end
