//
//  SIQuote.h
//  V2EX
//
//  Created by Silence on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SIQuoteType) {
    SIQuoteTypeNone,
    SIQuoteTypeUser,
    SIQuoteTypeEmail,
    SIQuoteTypeLink,
    SIQuoteTypeAppStore,
    SIQuoteTypeImage,
    SIQuoteTypeVedio,
    SIQuoteTypeTopic,
    SIQuoteTypeNode,
};
@interface SIQuote : NSObject

@property (nonatomic,copy) NSString *string;
@property (nonatomic,copy) NSString *identifier;
@property (nonatomic,assign)  SIQuoteType type;

@property (nonatomic,assign) NSRange range;
@property (nonatomic,strong) NSMutableArray *backgroundArray;

- (NSString *)quoteString;

@end
