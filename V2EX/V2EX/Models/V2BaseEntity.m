//
//  V2BaseEntity.m
//  V2EX
//
//  Created by 杨晴贺 on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

@implementation V2BaseEntity

- (NSString *)description{
    return [self yy_modelDescription] ;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [self yy_modelEncodeWithCoder:aCoder] ;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        [self yy_modelInitWithCoder:aDecoder] ;
    }
    return self ;
}

- (id)copyWithZone:(NSZone *)zone{
    return [self yy_modelCopy] ;
}

- (BOOL)isEqual:(id)object{
    return [self yy_modelIsEqual:object] ;
}

- (NSUInteger)hash{
    return [self yy_modelHash] ;
}



@end
