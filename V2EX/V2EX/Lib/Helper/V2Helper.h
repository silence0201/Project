//
//  V2Helper.h
//  V2EX
//
//  Created by Silence on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2Helper : NSObject

// Time & date
+ (NSArray *)localDateStringWithUTCString:(NSString *)dateString;
+ (NSArray *)localDateStringWithUTCString:(NSString *)dateString Separation:(NSString *)separation;
+ (NSTimeInterval)timeIntervalWithUTCString:(NSString *)dateString;
+ (NSString *)timeRemainDescriptionWithUTCString:(NSString *)dateString;
+ (NSString *)timeRemainDescriptionWithDateSP:(NSNumber *)dateSP;

// Setting
+ (UIImage *)getUserAvatarDefaultFromGender:(NSInteger)gender;

@end
