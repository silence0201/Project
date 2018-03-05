//
//  SIQuote.m
//  V2EX
//
//  Created by Silence on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "SIQuote.h"

@implementation SIQuote

- (instancetype)init {
    if (self = [super init]) {
        self.type = SIQuoteTypeNone;
        self.backgroundArray = [[NSMutableArray alloc] initWithCapacity:2];
    }
    return self;
}

- (NSString *)quoteString {
    NSString *typeString = @"";
    switch (self.type) {
        case SIQuoteTypeTopic:
            typeString = @"topic";
            break;
        case SIQuoteTypeUser:
            typeString = @"user";
            break;
        case SIQuoteTypeEmail:
            typeString = @"email";
            break;
        case SIQuoteTypeLink:
            typeString = @"link";
            break;
        case SIQuoteTypeAppStore:
            typeString = @"appStore";
            break;
        case SIQuoteTypeImage:
            typeString = @"image";
            break;
        case SIQuoteTypeVedio:
            typeString = @"vedio";
            break;
        case SIQuoteTypeNode:
            typeString = @"node";
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"[%@(%@)%@]", typeString, self.identifier, self.string];
}


@end
