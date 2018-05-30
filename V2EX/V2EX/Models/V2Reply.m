//
//  V2Reply.m
//  V2EX
//
//  Created by 杨晴贺 on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+SIMention.h"
#import "SIQuote.h"

@implementation V2Reply

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{@"replyId"  : @"id",
             @"replyThanksCount"  : @"thanks",
             @"replyModified"  : @"last_modified",
             @"replyCreated": @"created",
             @"replyContent"  : @"content",
             @"replyContentRendered"  : @"content_rendered",
             @"replyCreator": @"member",
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic{
    self.quoteArray = [self.replyContentRendered quoteArray];
    
    NSString *mentionString = self.replyContent;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.replyContent];
    [attributedString addAttribute:NSForegroundColorAttributeName value:kFontColorBlackDark range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, attributedString.length)];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    
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
                if (range.location > 0) {
                    [attributedString addAttribute:NSForegroundColorAttributeName value:(id)RGB(0x778087, 0.8) range:NSMakeRange(range.location - 1, 1)];
                }
            } else {
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
    
    self.attributedString = attributedString;
    
    self.imageURLs = imageURLs;
    
    
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
                        otherQuote.range = (NSMakeRange(otherQuote.range.location - lastStringIndex - stringOffset, otherQuote.range.length));
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
                otherQuote.range = (NSMakeRange(otherQuote.range.location - lastStringIndex - stringOffset, otherQuote.range.length));
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

@end

@implementation V2ReplyList

- (instancetype)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            V2Reply *model = [V2Reply yy_modelWithDictionary:dict];
            [list addObject:model];
        }
        self.list = list;
    }
    
    return self;
}

@end
