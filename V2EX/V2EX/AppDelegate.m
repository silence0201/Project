//
//  AppDelegate.m
//  V2EX
//
//  Created by Silence on 21/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "AppDelegate.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "V2DataManager.h"


#if DEBUG
#import <FLEX/FLEX.h>
#import <GDPerformanceView/GDPerformanceMonitor.h>
#endif

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelWarning;
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
#ifdef DEBUG
    [[GDPerformanceMonitor sharedInstance] startMonitoring];
    [[GDPerformanceMonitor sharedInstance] configureWithConfiguration:^(UILabel *textLabel) {
        [textLabel setBackgroundColor:[UIColor blackColor]];
        [textLabel setTextColor:[UIColor whiteColor]];
        [textLabel.layer setBorderColor:[[UIColor blackColor] CGColor]];
    }];
    [[FLEXManager sharedManager] setNetworkDebuggingEnabled:YES] ;
#endif
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [DDLog addLogger:fileLogger];
    
    UIViewController *vc = [[UIViewController alloc]init] ;
    vc.view.backgroundColor = [UIColor whiteColor] ;
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds] ;
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:vc] ;
    [self.window makeKeyAndVisible] ;


    [[V2DataManager manager]getCheckInCountSuccess:^(NSInteger count) {
        NSLog(@"%ld",count) ;
    } failure:^(NSError *error) {
        NSLog(@"%@",error) ;
    }] ;
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application{
#ifdef DEBUG
    [[GDPerformanceMonitor sharedInstance] stopMonitoring];
#endif
}

@end
