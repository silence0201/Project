//
//  V2NotificationManager.m
//  V2EX
//
//  Created by Silence on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2NotificationManager.h"
#import "V2Notification.h"

static NSString *const kNofiticationStoreFilePath = @"/notification.plist";

@interface V2NotificationManager ()

@property (nonatomic, strong) NSDate *lastUpdateDate;

@end

@implementation V2NotificationManager

- (instancetype)init {
    if (self = [super init]) {
        
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [path stringByAppendingString:kNofiticationStoreFilePath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                //                NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
                
            });
            
        } else {
            //            self.topicStateDictionary = [[NSMutableDictionary alloc] init];
        }
        
        //        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLeaveAppNotification) name:UIApplicationWillResignActiveNotification object:nil];
        
    }
    return self;
}

+ (instancetype)manager {
    static V2NotificationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[V2NotificationManager alloc] init];
    });
    return manager;
}


@end
