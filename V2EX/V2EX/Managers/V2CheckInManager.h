//
//  V2CheckInManager.h
//  V2EX
//
//  Created by Silence on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2BaseManager.h"

@interface V2CheckInManager : V2BaseManager

@property (nonatomic, assign) NSInteger checkInCount;
@property (nonatomic, assign, getter = isExpired) BOOL expired;
@property (nonatomic, strong) NSDate *lastCheckInDate;

- (void)resetStatus;
- (void)updateStatus;
- (void)removeStatus;

- (NSURLSessionDataTask *)checkInSuccess:(void (^)(NSInteger count))success
                                 failure:(void (^)(NSError *error))failure;

@end
