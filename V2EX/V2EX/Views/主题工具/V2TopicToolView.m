//
//  V2TopicToolView.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/24.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2TopicToolView.h"
#import "SIMetionTextView.h"

CGFloat const kMaxCircleOffsetX = 240.0;
CGFloat const kCircleHeight     = 28.0;

@interface V2TopicToolView ()

@property (nonatomic, assign) CGPoint          locationEnd;

@property (nonatomic, strong) UIView           *circleView;

@property (nonatomic, strong) SIMetionTextView *textView;

@property (nonatomic, strong) UIImageView      *backgroundImageView;
@property (nonatomic, strong) UIButton         *backgroundButton;

@property (nonatomic, assign) NSInteger        keyboardHeight;
@property (nonatomic, assign) NSInteger        sharpIndex;

@property (nonatomic, copy) NSString *contentString;

@property (nonatomic, assign, readwrite) BOOL isShowing;

@end

@implementation V2TopicToolView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor] ;
        self.userInteractionEnabled = NO ;
        _isShowing = NO ;
        [self setupViews] ;
        [self setupNotifications] ;
    }
    return self ;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViews{
    self.backgroundImageView = [[UIImageView alloc]init] ;
    self.backgroundImageView.backgroundColor = kBackgroundColorWhite ;
    self.backgroundImageView.alpha = 0.0 ;
    [self addSubview:self.backgroundImageView] ;
    
    self.textView  = [[SIMetionTextView alloc] initWithFrame:CGRectMake(10, 368 - kScreenHeight, kScreenWidth - 20, kScreenHeight - 368)];
    self.textView.textColor = kFontColorBlackDark;
    self.textView.layer.borderColor = kLineColorBlackLight.CGColor;
    self.textView.backgroundColor = kBackgroundColorWhite;
    self.textView.layer.borderWidth = 0.5;
    self.textView.font = [UIFont systemFontOfSize:17];
    self.textView.returnKeyType = UIReturnKeyDefault;
    self.textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.textView.contentInset = UIEdgeInsetsMake(2, 5, 0, 0) ;
    self.textView.showsHorizontalScrollIndicator = NO;
    self.textView.alwaysBounceHorizontal = NO;
    [self addSubview:self.textView];
    
    if (kCurrentTheme == V2ThemeNight) {
        self.textView.keyboardAppearance         = UIKeyboardAppearanceDark;
        self.textView.placeholderColor           = [UIColor colorWithRed:0.820 green:0.820 blue:0.840 alpha:0.240];
    } else {
        self.textView.keyboardAppearance         = UIKeyboardAppearanceDefault;
        self.textView.placeholderColor           = [UIColor colorWithRed:0.82f green:0.82f blue:0.84f alpha:1.00f];
    }
    
    // handles
    @weakify(self);
    [self.textView setTextViewDidChangeBlock:^(UITextView *textView) {
        @strongify(self);
        if (self.contentIsEmptyBlock) {
            self.contentIsEmptyBlock(textView.text.length == 0);
        }
    }];
    
    [self.backgroundButton bk_addEventHandler:^(id sender) {
        [self hideToolBar];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupNotifications{
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:kReplySuccessNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        [self hideToolBar];
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        CGRect keyboardFrame;
        [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
        self.keyboardHeight = keyboardFrame.size.height;
    }];
}

#pragma mark - Layout

- (void)layoutSubviews {
    self.backgroundImageView.frame = self.frame;
    self.backgroundButton.frame    = self.frame;
    self.circleView.frame          = (CGRect){321, 200, kCircleHeight, kCircleHeight};
    
    if (self.isCreate) {
        self.textView.placeholder      = @"输入主题内容";
        [self.backgroundButton bk_removeEventHandlersForControlEvents:UIControlEventTouchUpInside];
    } else {
        self.textView.placeholder      = @"让回复对别人有帮助";
    }
    
}

#pragma mark - Setters

- (void)setOffset:(CGFloat)offset {
    _offset = offset;
    if (self.isShowing) {
        return;
    }
    self.circleView.left = offset;
}

- (void)setLocationStart:(CGPoint)locationStart {
    _locationStart = locationStart;
    
    if (self.isShowing) {
        return;
    }
    
    if (self.locationStart.y > 100 && self.locationStart.y < self.height - 100) {
        [UIView animateWithDuration:0.1 animations:^{
            self.circleView.centerY = self.locationStart.y * 0.8;
            self.circleView.centerX = self.locationStart.x * 0.8;
        }];
        self.userInteractionEnabled = YES;
    }
}

#pragma mark - Public Methods

- (void)clearTextView {
    [self.textView removeAllQuotes];
    self.textView.text = @"";
}

- (void)popToolBar {
    [self hideToolBar];
}


- (void)showReplyViewWithQuotes:(NSArray *)quotes animated:(BOOL)animated {
    
    self.userInteractionEnabled = YES;
    self.isShowing = YES;
    
    if (quotes.count) {
        for (SIQuote *quote in quotes) {
            [self.textView addQuote:quote];
        }
    }
    
    if (animated) {
        [UIView animateWithDuration:0.1 animations:^{
            self.circleView.left = 321;
        } completion:^(BOOL finished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowReplyTextViewNotification object:nil];
            
            [self.textView becomeFirstResponder];
            
            [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:0.95 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.textView.top = 74;
            } completion:nil];
            
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.backgroundImageView.alpha = 1 ;
            } completion:nil];
        }];
    } else {
        self.circleView.left = 321;
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowReplyTextViewNotification object:nil];
        [self.textView becomeFirstResponder];
        self.textView.top = 74;
        self.backgroundImageView.alpha = 1;
    }
}


- (void)setLocationChanged:(CGPoint)locationChanged {
    _locationChanged = locationChanged;
    
    if (self.isShowing) {
        return;
    }
    
    if (self.isUserInteractionEnabled) {
        self.circleView.centerX = self.locationChanged.x * 0.4;
        self.circleView.centerY = self.locationChanged.y * 0.7;
    }
    
}

- (void)setLocationEnd:(CGPoint)locationEnd velocity:(CGPoint)velocity {
    _locationEnd = locationEnd;
}

- (void)setBlurredBackgroundImage:(UIImage *)blurredBackgroundImage {
    _blurredBackgroundImage = blurredBackgroundImage;
    self.backgroundImageView.image = self.blurredBackgroundImage;
    
}

- (NSString *)replyContentString {
    if (!self.contentString) {
        self.contentString = self.textView.renderedString;
    }
    return self.contentString;
}

- (BOOL)isContentEmpty {
    return self.textView.text.length == 0;
}


- (void)hideToolBar {
    self.isShowing = NO;
    self.userInteractionEnabled = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kHideReplyTextViewNotification object:nil];
    if (self.textView.top > 0) {
        [UIView animateWithDuration:0.1 animations:^{
            self.textView.top = 84;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1.05 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.textView.top = -self.textView.height;
            } completion:nil];
        }];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.circleView.left = 321;
        [self.textView resignFirstResponder];
        self.backgroundImageView.alpha = 0.0;
    }];
}


@end
