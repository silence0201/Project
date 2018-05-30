//
//  V2LoginViewController.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2LoginViewController.h"

static CGFloat const kContainViewYNormal = 120.0;
static CGFloat const kContainViewYEditing = 60.0;
@interface V2LoginViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton    *closeButton;
@property (nonatomic, strong) UIView      *containView;

@property (nonatomic, strong) UILabel     *logoLabel;
@property (nonatomic, strong) UILabel     *descriptionLabel;

@property (nonatomic, strong) UITextField *usernameField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UIButton    *loginButton;

@property (nonatomic, assign) BOOL isKeyboardShowing;
@property (nonatomic, strong) NSTimer *loginTimer;
@property (nonatomic, assign) BOOL isLogining;

@end

@implementation V2LoginViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
        self.isKeyboardShowing = NO;
        self.isLogining = NO;
    }
    return self ;
}

- (void)loadView{
    [super loadView] ;
    [self setupContainerViews] ;
    [self setupViews] ;
}

- (void)setupContainerViews{
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default-568_blurred"]];
    self.backgroundImageView.userInteractionEnabled = YES;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backgroundImageView];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self.closeButton setTintColor:[UIColor whiteColor]];
    self.closeButton.alpha = 0.5;
    [self.view addSubview:self.closeButton];
    
    self.containView = [[UIView alloc] init];
    [self.view addSubview:self.containView];
    
    self.logoLabel = [[UILabel alloc] init];
    self.logoLabel.text = @"V2EX";
    self.logoLabel.font = [UIFont fontWithName:@"Kailasa" size:36];
    self.logoLabel.textColor = kFontColorBlackDark;
    [self.logoLabel sizeToFit];
    [self.containView addSubview:self.logoLabel];
    
    self.descriptionLabel = [[UILabel alloc] init];
    self.descriptionLabel.text = @"V2EX是创意工作者们的社区";
    self.descriptionLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:18];
    self.descriptionLabel.textColor = kFontColorBlackLight;
    self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    [self.containView addSubview:self.descriptionLabel];
    
    // Handles
    @weakify(self);
    [self.closeButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self.containView bk_whenTapped:^{
        @strongify(self);
        [self hideKeyboard];
    }];
    
    [self.backgroundImageView bk_whenTapped:^{
        @strongify(self);
        [self hideKeyboard];
    }];
}

- (void)setupViews{
    self.usernameField = [[UITextField alloc] init];
    self.usernameField.textAlignment = NSTextAlignmentCenter;
    self.usernameField.textColor = kFontColorBlackDark;
    self.usernameField.font = [UIFont systemFontOfSize:18];
    self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"用户名"
                                                                               attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.836 alpha:1.000],
                                                                                            NSFontAttributeName:[UIFont italicSystemFontOfSize:18]}];
    self.usernameField.keyboardType = UIKeyboardTypeEmailAddress;
    self.usernameField.returnKeyType = UIReturnKeyNext;
    self.usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.usernameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.usernameField.rightViewMode = UITextFieldViewModeWhileEditing;
    [self.containView addSubview:self.usernameField];
    
    self.passwordField = [[UITextField alloc] init];
    self.passwordField.textAlignment = NSTextAlignmentCenter;
    self.passwordField.textColor = kFontColorBlackDark;
    self.passwordField.font = [UIFont systemFontOfSize:18];
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"密码"
                                                                               attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:0.836 alpha:1.000],
                                                                                                                    NSFontAttributeName:[UIFont italicSystemFontOfSize:18]}];
    self.passwordField.secureTextEntry = YES;
    self.passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordField.returnKeyType = UIReturnKeyGo;
    self.passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordField.rightViewMode = UITextFieldViewModeWhileEditing;
    [self.containView addSubview:self.passwordField];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:kFontColorBlackLight forState:UIControlStateHighlighted];
    self.loginButton.size = CGSizeMake(180, 44);
    [self.loginButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0.000 alpha:0.30] size:self.loginButton.size] forState:UIControlStateNormal] ;
    [self.loginButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:0.000 alpha:0.06] size:self.loginButton.size] forState:UIControlStateHighlighted] ;
    self.loginButton.layer.borderColor = [UIColor colorWithWhite:0.000 alpha:0.10].CGColor;
    self.loginButton.layer.borderWidth = 0.5;
    [self.containView addSubview:self.loginButton];
    
    // Handles
    @weakify(self);
    [self.usernameField setBk_shouldBeginEditingBlock:^BOOL(UITextField *textField) {
        @strongify(self);
        [self showKeyboard];
        return YES;
    }];

    [self.usernameField setBk_shouldReturnBlock:^BOOL(UITextField *textField) {
        @strongify(self);
        [self.passwordField becomeFirstResponder];
        return YES;
    }];
    
    [self.passwordField setBk_shouldBeginEditingBlock:^BOOL(UITextField *textField) {
        @strongify(self);
        [self showKeyboard];
        return YES;
    }];
    
    [self.passwordField setBk_shouldReturnBlock:^BOOL(UITextField *textField) {
        @strongify(self);
        [self login];
        return YES;
    }];
    
    [self.loginButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        [self login];
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    self.backgroundImageView.frame = self.view.frame;
    self.closeButton.frame = (CGRect){10, 20, 44, 44};
    
    self.containView.frame = (CGRect){0, kContainViewYNormal, kScreenWidth, 300};
    self.logoLabel.center = (CGPoint){kScreenWidth/2, 30};
    self.descriptionLabel.frame = (CGRect){20, 60, kScreenWidth - 20,70};
    self.usernameField.frame = (CGRect){60, 150, kScreenWidth - 120, 30};
    self.passwordField.frame = (CGRect){60, 190, kScreenWidth - 120, 30};
    self.loginButton.center = (CGPoint){kScreenWidth/2, 270};
    
}

#pragma mark --- Action
- (void)showKeyboard{
    if(!self.isKeyboardShowing){
        [UIView animateWithDuration:0.25 animations:^{
            self.containView.top = kContainViewYEditing;
            self.descriptionLabel.top -= 5;
            self.usernameField.top -= 10;
            self.passwordField.top -= 12;
            self.loginButton.top -= 14;
        }];
        self.isKeyboardShowing = YES;
    }
}

- (void)hideKeyboard{
    if(self.isKeyboardShowing){
        [UIView animateWithDuration:0.25 animations:^{
            self.containView.top = kContainViewYNormal;
            self.descriptionLabel.top += 5;
            self.usernameField.top += 10;
            self.passwordField.top += 12;
            self.loginButton.top += 14;
            [self.usernameField resignFirstResponder] ;
            [self.passwordField resignFirstResponder] ;
        }] ;
        self.isKeyboardShowing = NO ;
    }
}

- (void)login{
    if(!self.isLogining){
        if(self.usernameField.text.length && self.passwordField.text.length){
            if([self isValidEmail:self.usernameField.text]){
                [FFToast showToastWithTitle:@"账号错误" message:@"请输入用户账号,而不是注册邮箱" iconImage:[UIImage imageNamed:@"fftoast_error"] duration:2 toastType:FFToastTypeError] ;
                return ;
            }
            [self hideKeyboard] ;
            [[V2DataManager manager] userLoginWithUsername:self.usernameField.text password:self.passwordField.text success:^(NSString *message) {
                // 登陆成功
                [FFToast showToastWithTitle:@"登陆成功" message:nil iconImage:nil duration:2 toastType:FFToastTypeSuccess] ;
                
                // 获取用户信息
                [[V2DataManager manager] getMemberProfileWithUserId:nil username:self.usernameField.text success:^(V2Member *member) {
                    V2User *user = [[V2User alloc]init] ;
                    user.member = member ;
                    user.name = member.memberName ;
                    [V2UserManager manager].user = user ;
                    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessNotification object:nil] ;
                    [self endLogin] ;
                    [self dismissViewControllerAnimated:YES completion:nil];
                } failure:^(NSError *error) {
                    [FFToast showToastWithTitle:@"获取用户信息错误" message:@"获取用户信息错误,请重新登录" iconImage:nil duration:2 toastType:FFToastTypeError] ;
                    [self endLogin] ;
                }] ;
                
            } failure:^(NSError *error) {
                // 登陆失败
                NSString *reasonString;
                if (error.code < 700) {
                    reasonString = @"请检查网络状态";
                } else {
                    reasonString = @"请检查用户名或密码";
                }
                [FFToast showToastWithTitle:@"登陆错误" message:reasonString iconImage:nil duration:2 toastType:FFToastTypeError] ;
            }] ;
            [self beginLogin] ;
        }else{
            [FFToast showToastWithTitle:@"账号或密码不能为空" message:@"请检查用户名和密码信息" iconImage:nil duration:2 toastType:FFToastTypeError] ;
        }
    }
}


// 结束登陆
- (void)endLogin{
    self.usernameField.enabled = YES;
    self.passwordField.enabled = YES;
    
    [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
    
    self.isLogining = NO;
    
    [self.loginTimer invalidate];
    self.loginTimer = nil;
}

// 添加...
- (void)beginLogin{
    self.isLogining = YES;
    
    self.usernameField.enabled = NO;
    self.passwordField.enabled = NO;
    
    static NSUInteger dotCount = 0;
    dotCount = 1;
    [self.loginButton setTitle:@"登录." forState:UIControlStateNormal];
    
    @weakify(self);
    self.loginTimer = [NSTimer bk_scheduledTimerWithTimeInterval:0.5 block:^(NSTimer *timer) {
        @strongify(self);
        if (dotCount > 3) {
            dotCount = 0;
        }
        NSString *loginString = @"登录";
        for (int i = 0; i < dotCount; i ++) {
            loginString = [loginString stringByAppendingString:@"."];
        }
        dotCount ++;
        [self.loginButton setTitle:loginString forState:UIControlStateNormal];
        
    } repeats:YES];
}

- (BOOL)isValidEmail:(NSString *)email{
    if (email == nil) {
        return NO;
    }
    NSString *phoneRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:email];
}

#pragma mark - Keyboard Notification
- (void)keyboardWillHide:(NSNotification *)noti{
    [self hideKeyboard] ;
}

@end
