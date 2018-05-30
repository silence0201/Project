//
//  V2MenuView.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2MenuView.h"
#import "V2MenuSectionView.h"
#import "UIImage+Tint.h"

@interface V2MenuView ()

@property (nonatomic, strong) UIView      *backgroundContainView;
@property (nonatomic, strong) UIImageView *backgroundImageView;

@property (nonatomic, strong) UIImageView *leftShadowImageView;
@property (nonatomic, strong) UIView      *leftShdowImageMaskView;

@property (nonatomic, strong) V2MenuSectionView *sectionView;

@end

@implementation V2MenuView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.clipsToBounds = NO ;
        [self setupView] ;
        [self setupShadowView] ;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
    }
    return self ;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupView{
    self.backgroundContainView = [[UIView alloc] init];
    self.backgroundContainView.clipsToBounds = YES;
    [self addSubview:self.backgroundContainView];
    
    self.backgroundImageView = [[UIImageView alloc] init];
    [self.backgroundContainView addSubview:self.backgroundImageView];
    
    self.sectionView = [[V2MenuSectionView alloc] init];
    [self addSubview:self.sectionView];
    
    // Handles
    @weakify(self);
    [self.sectionView setDidSelectedIndexBlock:^(NSInteger index) {
        @strongify(self);
        if (self.selectedAction) {
            self.selectedAction(index);
        }
    }];
}

- (void)setupShadowView{
    self.leftShdowImageMaskView = [[UIView alloc] init];
    self.leftShdowImageMaskView.clipsToBounds = YES;
    [self addSubview:self.leftShdowImageMaskView];
    
    UIImage *shadowImage = [UIImage imageNamed:@"Navi_Shadow"];
    shadowImage = shadowImage.imageForCurrentTheme;
    
    self.leftShadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
    self.leftShadowImageView.transform = CGAffineTransformMakeRotation(M_PI);
    self.leftShadowImageView.alpha = 0.0;
    [self.leftShdowImageMaskView addSubview:self.leftShadowImageView];
}

#pragma mark --- layout
- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = kBackgroundColorWhiteDark;
    self.backgroundContainView.frame  = (CGRect){0, 0, self.width, kScreenHeight};
    self.backgroundImageView.frame = (CGRect){kScreenWidth, 0, kScreenWidth, kScreenHeight};
    self.leftShdowImageMaskView.frame = (CGRect){self.width, 0, 10, kScreenHeight};
    self.leftShadowImageView.frame = (CGRect){-5, 0, 10, kScreenHeight};
    self.sectionView.frame  = (CGRect){0, 0, self.width, kScreenHeight};
}

#pragma mark - Public Methods

- (void)setOffsetProgress:(CGFloat)progress {
    progress = MIN(MAX(progress, 0.0), 1.0);
    self.backgroundImageView.left = self.width - kScreenWidth/2 * progress;
    self.leftShadowImageView.alpha = progress;
    self.leftShadowImageView.left = -5 + progress * 5;
}

- (void)setBlurredImage:(UIImage *)blurredImage {
    _blurredImage = blurredImage;
    self.backgroundImageView.image = self.blurredImage;
}

- (void)selectIndex:(NSUInteger)index{
    self.sectionView.selectedIndex = index;
}

#pragma mark - Notifications

- (void)didReceiveThemeChangeNotification {
    [self setNeedsLayout];
    UIImage *shadowImage = [UIImage imageNamed:@"Navi_Shadow"];
    shadowImage  = shadowImage.imageForCurrentTheme;
    self.leftShadowImageView.image = shadowImage;
    self.backgroundImageView.image = nil;
}


@end
