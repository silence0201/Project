//
//  CAAnimation+Block.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "CAAnimation+Block.h"

@interface CAAnimationDelegate : NSObject<CAAnimationDelegate>

@property (nonatomic, copy) void (^completion)(BOOL, CALayer *);
@property (nonatomic, copy) void (^start)(void);

@end

@implementation CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim{
    if (self.start != nil) {
        self.start();
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (self.completion != nil) {
        CALayer *layer = [anim valueForKey:@"layer"];
        self.completion(flag, layer);
    }
}

@end

@implementation CAAnimation (Block)

- (void)setCompletion:(void (^)(BOOL, CALayer *))completion {
    if ([self.delegate isKindOfClass:[CAAnimationDelegate class]]) {
        ((CAAnimationDelegate *)self.delegate).completion = completion;
    }else {
        CAAnimationDelegate *delegate = [[CAAnimationDelegate alloc] init];
        delegate.completion = completion;
        self.delegate = delegate;
    }
}

- (void (^)(BOOL, CALayer *))completion{
    return [self.delegate isKindOfClass:[CAAnimationDelegate class]]? ((CAAnimationDelegate *)self.delegate).completion: nil;
}

- (void)setStart:(void (^)(void))start{
    if ([self.delegate isKindOfClass:[CAAnimationDelegate class]]) {
        ((CAAnimationDelegate *)self.delegate).start = start;
    }else {
        CAAnimationDelegate *delegate = [[CAAnimationDelegate alloc] init];
        delegate.start = start;
        self.delegate = delegate;
    }
}

- (void (^)(void))start{
    return [self.delegate isKindOfClass:[CAAnimationDelegate class]]? ((CAAnimationDelegate *)self.delegate).start: nil;
}


@end
