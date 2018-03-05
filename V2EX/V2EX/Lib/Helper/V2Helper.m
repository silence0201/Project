//
//  V2Helper.m
//  V2EX
//
//  Created by Silence on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2Helper.h"

@implementation V2Helper

+ (NSArray *)localDateStringWithUTCString:(NSString *)dateString {
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    [utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [utcDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *utcDate = [utcDateFormatter dateFromString:dateString];
    NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
    [localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [localDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *localTimeString = [localDateFormatter stringFromDate:utcDate];
    NSArray *localArray = [localTimeString componentsSeparatedByString:@" "];
    return localArray;
    
}

+ (NSArray *)localDateStringWithUTCString:(NSString *)dateString Separation:(NSString *)separation {
    
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    [utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [utcDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *utcDate = [utcDateFormatter dateFromString:dateString];
    
    NSDateFormatter *localDateFormatter = [[NSDateFormatter alloc] init];
    [localDateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *formateString = [NSString stringWithFormat:@"yyyy%@MM%@dd HH:mm", separation, separation];
    [localDateFormatter setDateFormat:formateString];
    NSString *localTimeString = [localDateFormatter stringFromDate:utcDate];
    NSArray *localArray = [localTimeString componentsSeparatedByString:@" "];
    return localArray;
    
}
+ (NSTimeInterval)timeIntervalWithUTCString:(NSString *)dateString {
    
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    [utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [utcDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *utcDate = [utcDateFormatter dateFromString:dateString];
    
    NSTimeInterval interval = [utcDate timeIntervalSinceNow];
    return interval;
}



+ (NSString *)timeRemainDescriptionWithUTCString:(NSString *)dateString {
    
    NSString *minuteStr = @"分钟";
    NSString *hourStr = @"小时";
    NSString *dayStr = @"天";
    
    NSTimeInterval interval = [self timeIntervalWithUTCString:dateString];
    
    
    NSString *before = @"";
    
    if (interval < 0) {
        interval = -interval;
        before = @"前";
    }
    
    CGFloat minute = interval / 60.0f;
    if (minute < 60.0f) {
        if (minute < 1.0f) {
            return @"刚刚";
        }
        return [NSString stringWithFormat:@"%.f%@%@", minute, minuteStr, before];
    } else {
        CGFloat hour = minute / 60.0f;
        if (hour < 24.0f) {
            return [NSString stringWithFormat:@"%.f%@%@", hour, hourStr, before];
        } else {
            CGFloat day = hour / 24.0f;
            if (day < 7.0f) {
                return [NSString stringWithFormat:@"%.f%@%@", day, dayStr, before];
            } else {
                NSArray *dateArray = [self localDateStringWithUTCString:dateString];
                if (dateArray.count == 2) {
                    return dateArray[0];
                } else {
                    return dateString;
                }
            }
        }
    }
    return nil;
    
}

+ (NSString *)timeRemainDescriptionWithDateSP:(NSNumber *)dateSP {
    
    NSDate *timesp = [NSDate dateWithTimeIntervalSince1970:[dateSP floatValue]];
    NSDateFormatter *utcDateFormatter = [[NSDateFormatter alloc] init];
    [utcDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [utcDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [utcDateFormatter stringFromDate:timesp];
    
    return [V2Helper timeRemainDescriptionWithUTCString:dateString];
}


/**
 *  Setting
 */

+ (UIImage *)getUserAvatarDefaultFromGender:(NSInteger)gender {
    
    if (gender == 2) {
        return [UIImage imageNamed:@"Avatar_User_Female"];
    } else {
        return [UIImage imageNamed:@"Avatar_User_Male"];
    }
}


@end
