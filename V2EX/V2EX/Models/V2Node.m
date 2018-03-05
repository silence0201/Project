//
//  V2Node.m
//  V2EX
//
//  Created by Silence on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2Node.h"

@implementation V2Node

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{@"nodeId"  : @"id",
             @"nodeName"  : @"name",
             @"nodeUrl"  : @"url",
             @"nodeTitleAlternative": @"title_alternative",
             @"nodeTitle"  : @"title",
             @"nodeTopicCount"  : @"topics",
             @"nodeFooter"  : @"footer",
             @"nodeHeader": @"header",
             @"nodeCreated": @"created",
             };
}

@end
