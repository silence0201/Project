//
//  V2BaseManager.m
//  V2EX
//
//  Created by 杨晴贺 on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2BaseManager.h"

@implementation V2BaseManager

+ (instancetype)manager{
    static V2BaseManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

@end
