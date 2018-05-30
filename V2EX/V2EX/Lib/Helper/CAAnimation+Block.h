//
//  CAAnimation+Block.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CAAnimation (Block)

@property (nonatomic, copy) void (^completion)(BOOL finished, CALayer *layer);
@property (nonatomic, copy) void (^start)(void);

@end
