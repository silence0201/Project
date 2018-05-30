//
//  NSString+SIMention.m
//  V2EX
//
//  Created by 杨晴贺 on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "NSString+SIMention.h"
#import "SIQuote.h"
#import <SIHTMLParser/HTMLParser.h>

@implementation NSString (SIMention)

- (NSArray *)quoteArray {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    @autoreleasepool {
        
        NSString *mentionString = self;
        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:[NSString stringWithFormat:@"<body>%@</body>", self] error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
        }
        
        HTMLNode *bodyNode = [parser body];
        mentionString = bodyNode.allContents;
        
        // a Tag
        NSArray *aNodes = [bodyNode findChildrenTag:@"a"];
        for (HTMLNode *aNode in aNodes) {
            NSString *hrefString = [aNode getAttributeNamed:@"href"];
            SIQuote *quote = [[SIQuote alloc] init];
            if ([hrefString hasPrefix:@"/member/"]) {
                NSString *identifier = [hrefString stringByReplacingOccurrencesOfString:@"/member/" withString:@""];
                quote.identifier = identifier;
                quote.string = identifier;
                quote.type = SIQuoteTypeUser;
            }
            if ([hrefString hasPrefix:@"/t/"]) {
                NSString *identifier = [hrefString stringByReplacingOccurrencesOfString:@"/t/" withString:@""];
                quote.identifier = identifier;
                quote.string = aNode.allContents;
                quote.type = SIQuoteTypeTopic;
            }
            if ([hrefString hasPrefix:@"mailto:"]) {
                NSString *identifier = [hrefString stringByReplacingOccurrencesOfString:@"mailto:" withString:@""];
                quote.identifier = identifier;
                quote.string = identifier;
                quote.type = SIQuoteTypeEmail;
            }
            if ([hrefString hasSuffix:@"jpeg"] ||
                [hrefString hasSuffix:@"png"] ||
                [hrefString hasSuffix:@"jpg"] ||
                [hrefString hasSuffix:@"gif"]) {
                
                NSString *identifier = hrefString;
                
                HTMLNode *imageNode = [aNode findChildTag:@"img"];
                identifier = [imageNode getAttributeNamed:@"src"];
                
                if (!identifier) {
                    identifier = hrefString;
                }
                
                quote.string = identifier;
                if ([identifier rangeOfString:@"http://www.v2ex.com/i/"].location != NSNotFound) {
                    identifier = [identifier stringByReplacingOccurrencesOfString:@"http://www.v2ex.com/i/" withString:@"http://i.v2ex.co/"];
                }
                quote.identifier = identifier;
                quote.type = SIQuoteTypeImage;
                
            }
            
            if ([hrefString rangeOfString:@"v2ex.com/t/"].location != NSNotFound) {
                NSString *identifier = [hrefString componentsSeparatedByString:@"v2ex.com/t/"].lastObject;
                identifier = [identifier componentsSeparatedByString:@"#"].firstObject;
                
                quote.identifier = identifier;
                quote.string = aNode.allContents;
                quote.type = SIQuoteTypeTopic;
                
            }
            if ([hrefString rangeOfString:@"itunes.apple.com"].location != NSNotFound) {
                quote.identifier = hrefString;
                quote.string = hrefString;
                quote.type = SIQuoteTypeAppStore;
            }
            
            if (quote.type == SIQuoteTypeNone) {
                quote.identifier = hrefString;
                quote.string = hrefString;
                quote.type = SIQuoteTypeLink;
            }
            
            quote.identifier = [quote.identifier stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            quote.string = [quote.string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (!quote.identifier) {
                quote.identifier = hrefString;
            }
            if (!quote.string) {
                quote.string = hrefString;
            }
            [array addObject:quote];
        }
        
        // Img Tag
        NSArray *imageNodes = [bodyNode findChildrenTag:@"img"] ;
        for (HTMLNode *imageNode in imageNodes){
            NSString *srcStr = [imageNode getAttributeNamed:@"src"] ;
            srcStr = [srcStr componentsSeparatedByString:@"?"].firstObject;
            SIQuote *quote = [[SIQuote alloc]init] ;
            if(srcStr.length > 0){
                quote.identifier = srcStr ;
                quote.string = srcStr ;
                quote.type = SIQuoteTypeImage ;
            }
            
            if (quote.type == SIQuoteTypeNode){
                quote.identifier = srcStr ;
                quote.string = srcStr ;
                quote.type = SIQuoteTypeLink ;
            }
            [array addObject:quote] ;
        }
        
    }
    return array;
    
}


@end
