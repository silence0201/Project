//
//  V2Member.m
//  V2EX
//
//  Created by Silence on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2Member.h"

@implementation V2Member

+ (nullable NSDictionary<NSString *, id> *)modelCustomPropertyMapper{
    return @{@"memberId"  : @"id",
             @"memberName"  : @"username",
             @"memberAvatarMini"  : @"avatar_mini",
             @"memberAvatarNormal": @"avatar_normal",
             @"memberAvatarLarge"  : @"avatar_large",
             @"memberTagline"  : @"tagline",
             @"memberBio"  : @"bio",
             @"memberCreated": @"created",
             @"memberLocation"  : @"location",
             @"memberStatus"  : @"status",
             @"memberTwitter": @"twitter",
             @"memberUrl"  : @"url",
             @"memberWebsite"  : @"website",
             @"memberPsn"  : @"psn",
             @"memberGithub"  : @"github",
             @"memberBtc"  : @"btc"
             };
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic{
    if ([self.memberAvatarMini hasPrefix:@"//"]) {
        self.memberAvatarMini = [@"http:" stringByAppendingString:self.memberAvatarMini];
    }
    
    if ([self.memberAvatarNormal hasPrefix:@"//"]) {
        self.memberAvatarNormal = [@"http:" stringByAppendingString:self.memberAvatarNormal];
    }
    
    if ([self.memberAvatarLarge hasPrefix:@"//"]) {
        self.memberAvatarLarge = [@"http:" stringByAppendingString:self.memberAvatarLarge];
    }
    return YES ;
}


@end
