//
//  SIBarButtonItem.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SIBarButtonItem : NSObject

@property (nonatomic, strong) UIView *view;

@property (nonatomic, assign, getter = isEnabled) BOOL enabled;
@property (nonatomic, copy) NSString *badge;

- (instancetype)initWithTitle:(NSString *)title handler:(void (^)(id sender))action;
- (instancetype)initWithImage:(UIImage *)image  handler:(void (^)(id sender))action;

@end
