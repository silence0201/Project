//
//  SINavigationController.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "SINavigationController.h"
#import "UIImage+Tint.h"

static const CGFloat kToBackgroundInitAlpha = 0.08;

@interface SINavigationPopAnimation ()

@property (nonatomic, strong) UIView      *toBackgroundView;
@property (nonatomic, strong) UIImageView *shadowImageView;
@property (nonatomic, strong) UIImageView *maskImageView;

@property (nonatomic, strong) UIView      *naviContainView;

@end

@implementation SINavigationPopAnimation

- (instancetype)init {
    if (self = [super init]) {
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
        self.toBackgroundView = [[UIView alloc] init];
        
        self.shadowImageView = [[UIImageView alloc] initWithFrame:(CGRect){-10, 0, 10, screenHeight}];
        self.shadowImageView.image = [UIImage imageNamed:@"Navi_Shadow"];
        self.shadowImageView.contentMode = UIViewContentModeScaleToFill;
        
        self.maskImageView = [[UIImageView alloc] initWithFrame:(CGRect){0, 20, kScreenWidth, 44}];
        self.maskImageView.image = [UIImage imageNamed:@"navi_mask"];
        
        self.naviContainView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 64}];
        self.naviContainView.backgroundColor = [UIColor colorWithRed:0.774 green:0.368 blue:1.000 alpha:0.810];
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    [containerView addSubview:fromViewController.view];
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    [containerView insertSubview:self.toBackgroundView belowSubview:fromViewController.view];
    [containerView insertSubview:self.shadowImageView belowSubview:fromViewController.view];
    toViewController.view.frame = CGRectMake(-90, 0, kScreenWidth, CGRectGetHeight(toViewController.view.frame));
    self.toBackgroundView.frame = CGRectMake(-90, 0, kScreenWidth, CGRectGetHeight(toViewController.view.frame));
    self.shadowImageView.left = - 10;
    self.shadowImageView.alpha = 1.3;
    
    self.toBackgroundView.backgroundColor = [UIColor blackColor];
    self.shadowImageView.image = self.shadowImageView.image.imageForCurrentTheme;
    self.maskImageView.image = [self.maskImageView.image imageWithTintColor:kBackgroundColorWhite];
    self.toBackgroundView.alpha = kToBackgroundInitAlpha;
    
    // Configure Navi Transition
    
    UIView *naviBarView;
    
    UIView *toNaviLeft;
    UIView *toNaviRight;
    UIView *toNaviTitle;
    
    UIView *fromNaviLeft;
    UIView *fromNaviRight;
    UIView *fromNaviTitle;
    
    if (fromViewController.isNavigationBarHidden || toViewController.isNavigationBarHidden) {
        ;
    } else {
        
        naviBarView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 64}];
        naviBarView.backgroundColor = kNavigationBarColor;
        [containerView addSubview:naviBarView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){0, 64, kScreenWidth, 0.5}];
        lineView.backgroundColor = kNavigationBarLineColor;
        [naviBarView addSubview:lineView];
        
        toNaviLeft = toViewController.naviItem.leftBarButtonItem.view;
        toNaviRight = toViewController.naviItem.rightBarButtonItem.view;
        toNaviTitle = toViewController.naviItem.titleLabel;
        
        fromNaviLeft = fromViewController.naviItem.leftBarButtonItem.view;
        fromNaviRight = fromViewController.naviItem.rightBarButtonItem.view;
        fromNaviTitle = fromViewController.naviItem.titleLabel;
        
        [containerView addSubview:toNaviTitle];
        [containerView addSubview:fromNaviTitle];
        
        [containerView addSubview:self.maskImageView];
        
        [containerView addSubview:toNaviLeft];
        [containerView addSubview:toNaviRight];
        
        [containerView addSubview:fromNaviLeft];
        [containerView addSubview:fromNaviRight];
        
        fromNaviLeft.alpha = 1.0;
        fromNaviRight.alpha =  1.0;
        fromNaviTitle.alpha = 1.0;
        fromNaviLeft.left = 0;
        fromNaviRight.left = kScreenWidth - fromNaviRight.width;
        fromNaviLeft.transform = CGAffineTransformIdentity;
        fromNaviRight.transform = CGAffineTransformIdentity;
        
        toNaviLeft.alpha = 0.0;
        toNaviRight.alpha = 0.0;
        toNaviTitle.alpha = 0.0;
        toNaviTitle.centerX = 44;
        toNaviRight.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
    }
    
    // End configure
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        toViewController.view.left = 0;
        self.toBackgroundView.left = 0;
        fromViewController.view.left = kScreenWidth;
        
        self.shadowImageView.alpha = 0.2;
        self.shadowImageView.left = kScreenWidth - 7;
        
        self.toBackgroundView.alpha = 0.0;
        fromNaviLeft.alpha = 0;
        fromNaviRight.alpha =  0;
        fromNaviTitle.alpha = 0;
        fromNaviTitle.centerX = kScreenWidth + 10;
        fromNaviLeft.transform = CGAffineTransformMakeScale(0.1, 0.1);
        fromNaviRight.transform = CGAffineTransformMakeScale(0.1, 0.1);
        
        toNaviLeft.alpha = 1.0;
        toNaviRight.alpha = 1.0;
        toNaviTitle.alpha = 1.0;
        toNaviTitle.centerX = kScreenWidth / 2;
        toNaviRight.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
        if (transitionContext.transitionWasCancelled) {
            toNaviLeft.alpha = 1.0;
            toNaviRight.alpha = 1.0;
            toNaviTitle.alpha = 1.0;
            toNaviTitle.centerX = kScreenWidth / 2;
            toNaviLeft.transform = CGAffineTransformIdentity;
            toNaviRight.transform = CGAffineTransformIdentity;
            self.toBackgroundView.alpha = kToBackgroundInitAlpha;
        }
        
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        
        [naviBarView removeFromSuperview];
        [self.maskImageView removeFromSuperview];
        [self.toBackgroundView removeFromSuperview];
        
        [toNaviLeft removeFromSuperview];
        [toNaviTitle removeFromSuperview];
        [toNaviRight removeFromSuperview];
        
        [fromNaviLeft removeFromSuperview];
        [fromNaviTitle removeFromSuperview];
        [fromNaviRight removeFromSuperview];
        
        [toViewController.naviBar addSubview:toNaviLeft];
        [toViewController.naviBar addSubview:toNaviTitle];
        [toViewController.naviBar addSubview:toNaviRight];
        
        [fromViewController.naviBar addSubview:fromNaviLeft];
        [fromViewController.naviBar addSubview:fromNaviTitle];
        [fromViewController.naviBar addSubview:fromNaviRight];
    }];
}

@end

@implementation SINavigationPushAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    [containerView addSubview:fromViewController.view];
    [containerView addSubview:toViewController.view];
    fromViewController.view.frame = CGRectMake(0, 0, kScreenWidth, CGRectGetHeight(fromViewController.view.frame));
    toViewController.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, CGRectGetHeight(toViewController.view.frame));
    
    
    UIView *naviBarView;
    
    UIView *toNaviLeft;
    UIView *toNaviRight;
    UIView *toNaviTitle;
    
    UIView *fromNaviLeft;
    UIView *fromNaviRight;
    UIView *fromNaviTitle;
    
    if (fromViewController.isNavigationBarHidden || toViewController.isNavigationBarHidden) {
        ;
    } else {
        naviBarView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 64}];
        naviBarView.backgroundColor = kNavigationBarColor;
        [containerView addSubview:naviBarView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){0, 64, kScreenWidth, 0.5}];
        lineView.backgroundColor = kNavigationBarLineColor;
        [naviBarView addSubview:lineView];
        
        toNaviLeft = toViewController.naviItem.leftBarButtonItem.view;
        toNaviRight = toViewController.naviItem.rightBarButtonItem.view;
        toNaviTitle = toViewController.naviItem.titleLabel;
        
        fromNaviLeft = fromViewController.naviItem.leftBarButtonItem.view;
        fromNaviRight = fromViewController.naviItem.rightBarButtonItem.view;
        fromNaviTitle = fromViewController.naviItem.titleLabel;
        
        [containerView addSubview:toNaviLeft];
        [containerView addSubview:toNaviTitle];
        [containerView addSubview:toNaviRight];
        
        [containerView addSubview:fromNaviLeft];
        [containerView addSubview:fromNaviTitle];
        [containerView addSubview:fromNaviRight];
        
        fromNaviLeft.alpha = 1.0;
        fromNaviRight.alpha =  1.0;
        fromNaviTitle.alpha = 1.0;
        
        toNaviLeft.alpha = 0.0;
        toNaviRight.alpha = 0.0;
        toNaviTitle.alpha = 0.0;
        toNaviTitle.centerX = 44;
        
        toNaviLeft.left = 0;
        toNaviTitle.centerX = kScreenWidth;
        toNaviRight.left = kScreenWidth + 50 - toNaviRight.width;
        
    }
    
    // End configure
    [UIView animateWithDuration:duration animations:^{
        toViewController.view.left = 0;
        fromViewController.view.left = -120;
        
        fromNaviLeft.alpha = 0;
        fromNaviRight.alpha =  0;
        fromNaviTitle.alpha = 0;
        fromNaviTitle.centerX = 0;
        
        toNaviLeft.alpha = 1.0;
        toNaviRight.alpha = 1.0;
        toNaviTitle.alpha = 1.0;
        toNaviTitle.centerX = kScreenWidth/2;
        toNaviLeft.left = 0;
        toNaviRight.left = kScreenWidth - toNaviRight.width;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        
        fromNaviLeft.alpha = 1.0;
        fromNaviRight.alpha = 1.0;
        fromNaviTitle.alpha = 1.0;
        fromNaviTitle.centerX = kScreenWidth / 2;
        fromNaviLeft.left = 0;
        fromNaviRight.left = kScreenWidth - fromNaviRight.width;
        
        [naviBarView removeFromSuperview];
        
        [toNaviLeft removeFromSuperview];
        [toNaviTitle removeFromSuperview];
        [toNaviRight removeFromSuperview];
        
        [fromNaviLeft removeFromSuperview];
        [fromNaviTitle removeFromSuperview];
        [fromNaviRight removeFromSuperview];
        
        [toViewController.naviBar addSubview:toNaviLeft];
        [toViewController.naviBar addSubview:toNaviTitle];
        [toViewController.naviBar addSubview:toNaviRight];
        
        [fromViewController.naviBar addSubview:fromNaviLeft];
        [fromViewController.naviBar addSubview:fromNaviTitle];
        [fromViewController.naviBar addSubview:fromNaviRight];
    }];
}

@end


@interface SINavigationController ()<UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactivePopTransition;

@property (nonatomic, assign) UIViewController *lastViewController;

@end

@implementation SINavigationController

#pragma mark --- init
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.enableInnerInactiveGesture = YES;
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        self.enableInnerInactiveGesture = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBarHidden = YES;
    
    self.interactivePopGestureRecognizer.delegate = self;
    super.delegate = self;
    
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanRecognizer:)];
    //AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //appDelegate.currentNavigationController = self;
}

#pragma mark - Push & Pop

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] postNotificationName:kRootViewControllerCancelDelegateNotification object:nil];
    [self configureNavigationBarForViewController:viewController];
    [super pushViewController:viewController animated:animated];
}

#pragma mark - UINavigationDelegate
// forbid User VC to be NavigationController's delegate
- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate{
    
    [viewController.view bringSubviewToFront:viewController.naviBar];
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if (navigationController.viewControllers.count == 1) {
            self.interactivePopGestureRecognizer.delegate = nil;
            self.delegate = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:kRootViewControllerResetDelegateNotification object:nil];
            self.interactivePopGestureRecognizer.enabled = NO;
        } else {
            self.interactivePopGestureRecognizer.enabled = YES;
        }
    }
    
    if (self.enableInnerInactiveGesture) {
        BOOL hasPanGesture = NO;
        BOOL hasEdgePanGesture = NO;
        for (UIGestureRecognizer *recognizer in [viewController.view gestureRecognizers]) {
            if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
                    hasEdgePanGesture = YES;
                } else {
                    hasPanGesture = YES;
                }
            }
        }
        if (!hasPanGesture && (navigationController.viewControllers.count > 1)) {
            [viewController.view addGestureRecognizer:self.panRecognizer];
        }
    }
    
    viewController.navigationController.delegate = self;
    
    //AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    //appDelegate.currentNavigationController = (SINavigationController *)viewController.navigationController;
}


// Animation
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPop && navigationController.viewControllers.count >= 1 && self.enableInnerInactiveGesture) {
        return [[SINavigationPopAnimation alloc] init];
    } else if (operation == UINavigationControllerOperationPush) {
        SINavigationPushAnimation *animation = [[SINavigationPushAnimation alloc] init];
        return animation;
    } else {
        return nil;
    }
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([animationController isKindOfClass:[SINavigationPopAnimation class]] && self.enableInnerInactiveGesture) {
        return self.interactivePopTransition;
    }else {
        return nil;
    }
}

#pragma mark --- Action
- (void)handlePanRecognizer:(UIPanGestureRecognizer*)recognizer {
    if (!self.enableInnerInactiveGesture) {
        return;
    }
    static CGFloat startLocationX = 0;
    CGPoint location = [recognizer locationInView:self.view];
    CGFloat progress = (location.x - startLocationX) / kScreenWidth;
    progress = MIN(1.0, MAX(0.0, progress));
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        startLocationX = location.x;
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self popViewControllerAnimated:YES];
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGFloat velocityX = [recognizer velocityInView:self.view].x;
        if (progress > 0.3 || velocityX > 300) {
            self.interactivePopTransition.completionSpeed = 0.4;
            [self.interactivePopTransition finishInteractiveTransition];
        }else {
            self.interactivePopTransition.completionSpeed = 0.3;
            [self.interactivePopTransition cancelInteractiveTransition];
        }
        self.interactivePopTransition = nil;
    }
}


#pragma mark - Private Helper
- (void)configureNavigationBarForViewController:(UIViewController *)viewController {
    [[self class] createNavigationBarForViewController:viewController];
}

+ (void)createNavigationBarForViewController:(UIViewController *)viewController {
    if (!viewController.naviItem) {
        SINavigationItem *navigationItem = [[SINavigationItem alloc] init];
        [navigationItem setValue:viewController forKey:@"_viewController"];
        viewController.naviItem = navigationItem;
    }
    if (!viewController.naviBar) {
        viewController.naviBar = [[SINavigationBar alloc] init];
        [viewController.view addSubview:viewController.naviBar];
    }
}

@end
