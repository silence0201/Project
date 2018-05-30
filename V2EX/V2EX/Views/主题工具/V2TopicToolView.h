//
//  V2TopicToolView.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/24.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2TopicToolView : UIView

@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, assign) CGPoint locationStart;
@property (nonatomic, assign) CGPoint locationChanged;

@property (nonatomic, assign, getter = isCreate) BOOL create;
@property (nonatomic, readonly) BOOL isShowing;

@property (nonatomic, strong) UIImage *blurredBackgroundImage;

@property (nonatomic, copy, readonly) NSString *replyContentString;
@property (nonatomic, assign, readonly, getter = isContentEmpty) BOOL contentEmpty;
@property (nonatomic, copy) void (^contentIsEmptyBlock)(BOOL isEmpty);

@property (nonatomic, copy) void (^insertImageBlock)();

- (void)setLocationEnd:(CGPoint)locationEnd velocity:(CGPoint)velocity;

- (void)showReplyViewWithQuotes:(NSArray *)quotes animated:(BOOL)animated;

- (void)clearTextView;

- (void)popToolBar;

@end
