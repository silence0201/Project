//
//  V2TopicReplyCell.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/24.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2TopicReplyCell.h"

#import <IDMPhotoBrowser/IDMPhotoBrowser.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

#import "SIQuote.h"
#import "UIImage+Tint.h"
#import "V2Helper.h"

#import "V2TopicViewController.h"
#import "V2MemberViewController.h"
#import "V2RootViewController.h"
#import "V2WebViewController.h"

static CGFloat const kAvatarHeight = 30.0f;
static CGFloat const kNameFontSize = 15.0f;
static CGFloat const kContentFontSize = 15.0f;
#define kNameLabelWidth (kScreenWidth - 76)
#define kContentLabelWidth (kScreenWidth - 60)

@interface V2TopicReplyCell () <TTTAttributedLabelDelegate, IDMPhotoBrowserDelegate>

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton    *avatarButton;
@property (nonatomic, strong) TTTAttributedLabel     *contentLabel;

@property (nonatomic, strong) NSMutableArray *attributedLabelArray;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *imageButtonArray;
@property (nonatomic, strong) NSMutableArray *imageUrls;

@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UILabel     *timeLabel;

@property (nonatomic, strong) UIView      *borderLineView;

@property (nonatomic, assign) NSInteger   titleHeight;
@property (nonatomic, assign) NSInteger   descriptionHeight;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;

@property (nonatomic, strong) UIColor *highlightedColorLightBlue;
@property (nonatomic, strong) UIColor *highlightedColorLightBlack;

@end


@implementation V2TopicReplyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.clipsToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor = kBackgroundColorWhite;
        
        self.attributedLabelArray = [[NSMutableArray alloc] init];
        self.imageArray = [[NSMutableArray alloc] init];
        self.imageButtonArray = [[NSMutableArray alloc] init];
        self.imageUrls = [[NSMutableArray alloc] init];
        
        self.avatarImageView                    = [[UIImageView alloc] init];
        self.avatarImageView.image              = [UIImage imageNamed:@"default_avatar"];
        self.avatarImageView.contentMode        = UIViewContentModeScaleAspectFill;
        self.avatarImageView.clipsToBounds      = YES ;
        [self addSubview:self.avatarImageView];
        
        self.avatarButton                       = [UIButton buttonWithType:UIButtonTypeCustom];
        self.avatarButton.clipsToBounds         = YES ;
        [self addSubview:self.avatarButton];
        
        self.nameLabel                          = [[UILabel alloc] init];
        self.nameLabel.backgroundColor          = [UIColor clearColor];
        self.nameLabel.textColor                = kFontColorBlackDark;
        self.nameLabel.font                     = [UIFont boldSystemFontOfSize:kNameFontSize];;
        [self addSubview:self.nameLabel];
        
        self.contentLabel  = [self createAttributedLabel];
        
        self.timeLabel                          = [[UILabel alloc] init];
        self.timeLabel.backgroundColor          = [UIColor clearColor];
        self.timeLabel.textColor                = kFontColorBlackLight;
        self.timeLabel.font                     = [UIFont systemFontOfSize:13];;
        self.timeLabel.textAlignment            = NSTextAlignmentRight;
        self.timeLabel.alpha = 0.6;
        [self addSubview:self.timeLabel];
        
        self.highlightedColorLightBlue = [UIColor colorWithRed:0.055 green:0.597 blue:1.000 alpha:0.015];
        self.highlightedColorLightBlack = [UIColor colorWithRed:0.102 green:0.665 blue:0.971 alpha:0.080];
        // Handles
        @weakify(self);
        [self.avatarButton bk_addEventHandler:^(id sender) {
            @strongify(self);
            V2MemberViewController *profileVC = [[V2MemberViewController alloc] init];
            profileVC.member = self.model.replyCreator;
            [self.navi pushViewController:profileVC animated:YES];
        } forControlEvents:UIControlEventTouchUpInside];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveSelectMemberNotification:) name:kSelectMemberNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.avatarImageView.frame = (CGRect){10, 12, kAvatarHeight, kAvatarHeight};
    self.avatarButton.frame = (CGRect){0, 0, kAvatarHeight + 15, kAvatarHeight + 20};
    
    self.nameLabel.origin      = CGPointMake(50, 10);
    self.contentLabel.frame    = CGRectMake(50, 8 + self.titleHeight + 8, kContentLabelWidth, self.descriptionHeight);
    
    self.timeLabel.origin      = CGPointMake(self.nameLabel.left + self.nameLabel.width + 8, self.nameLabel.top + 2);
    
    self.borderLineView.frame  = CGRectMake(0, self.height-0.5, kScreenWidth, 0.5);
    
    if ([self.model.replyCreator.memberName isEqualToString:self.selectedReplyModel.replyCreator.memberName]) {
        self.backgroundColor = self.highlightedColorLightBlack;
    } else {
        self.backgroundColor = kBackgroundColorWhite;
    }
    
    self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
    
    @weakify(self);
    if (self.model.contentArray) {
        [self.imageArray enumerateObjectsUsingBlock:^(UIImageView *imageView, NSUInteger idx, BOOL *stop) {
            @strongify(self);
            if (idx < self.model.imageURLs.count) {
                imageView.hidden = NO;
            } else {
                imageView.hidden = YES;
            }
        }];
        [self.imageButtonArray enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
            @strongify(self);
            if (idx < self.model.imageURLs.count) {
                button.hidden = NO;
            } else {
                button.hidden = YES;
            }
        }];
        [self.attributedLabelArray enumerateObjectsUsingBlock:^(TTTAttributedLabel *label, NSUInteger idx, BOOL *stop) {
            label.hidden = NO;
        }];
        [self layoutContent];
    }
}

- (void)setModel:(V2Reply *)model {
    _model = model;
    
    @weakify(self);
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.replyCreator.memberAvatarNormal] placeholderImage:[UIImage imageNamed:@"default_avatar"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        @strongify(self);
        if (!image.cached) {
            UIImage *cornerRadiusImage = [image imageWithCornerRadius:3];
            cornerRadiusImage.cached = YES;
            [[SDWebImageManager sharedManager].imageCache storeImage:cornerRadiusImage
                                                              forKey:model.replyCreator.memberAvatarNormal];
            self.avatarImageView.image = cornerRadiusImage;
        }
    }] ;

    self.nameLabel.text    = model.replyCreator.memberName;
    self.timeLabel.text    = [V2Helper timeRemainDescriptionWithDateSP:model.replyCreated];
    [self.timeLabel sizeToFit];
    
    self.nameLabel.text    = model.replyCreator.memberName;
    [self.nameLabel sizeToFit];
    
    self.titleHeight = [model.replyCreator.memberName heightForFont:[UIFont systemFontOfSize:kNameFontSize] width:kNameLabelWidth]+1 ;
    
    if (!model.contentArray) {
        self.descriptionHeight = [TTTAttributedLabel sizeThatFitsAttributedString:model.attributedString withConstraints:(CGSize){kContentLabelWidth, 0} limitedToNumberOfLines:0].height;
        self.contentLabel.text = model.attributedString;
        for (SIQuote *quote in model.quoteArray) {
            [self.contentLabel addLinkToURL:[NSURL URLWithString:quote.identifier] withRange:quote.range];
        }
        
    }
}

- (void)layoutContent {
    __block NSUInteger labelIndex = 0;
    __block NSUInteger imageIndex = 0;
    __block CGFloat offsetY = 8 + self.titleHeight + 8;
    @weakify(self);
    [self.model.contentArray enumerateObjectsUsingBlock:^(V2ContentBase *baseModel, NSUInteger idx, BOOL *stop) {
        @strongify(self);
        
        if (baseModel.contentType == V2ContentTypeString) {
            V2ContentString *stringModel = (V2ContentString *)baseModel;
            TTTAttributedLabel *label;
            if (self.attributedLabelArray.count <= labelIndex) {
                label = [self createAttributedLabel];
            } else {
                label = self.attributedLabelArray[labelIndex];
            }
            label.attributedText = stringModel.attributedString;
            CGFloat labelHeight = [TTTAttributedLabel sizeThatFitsAttributedString:stringModel.attributedString withConstraints:(CGSize){kContentLabelWidth, 0} limitedToNumberOfLines:0].height;
            
            if (stringModel.attributedString.length == 0) {
                labelHeight = 0;
            }
            label.size = (CGSize){kContentLabelWidth, labelHeight};
            label.origin = (CGPoint){50, offsetY};
            
            for (SIQuote *quote in stringModel.quoteArray) {
                [label addLinkToURL:[NSURL URLWithString:quote.identifier] withRange:quote.range];
            }
            labelIndex ++;
            offsetY += (label.height + 7);
        }
        
        if (baseModel.contentType == V2ContentTypeImage) {
            V2ContentImage *imageModel = (V2ContentImage *)baseModel;
            UIImageView *imageView;
            if (self.imageArray.count <= imageIndex) {
                imageView = [self createImageView];
            } else {
                imageView = self.imageArray[imageIndex];
            }
            
            CGSize imageSize = [[self class] imageSizeForKey:imageModel.imageQuote.identifier];
            imageView.size = imageSize;
            imageView.origin = (CGPoint){50, offsetY};
            
            UIImage *cachedImage = [[self class] imageForKey:imageModel.imageQuote.identifier];
            if (cachedImage) {
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.image = cachedImage;
                imageView.backgroundColor = [UIColor clearColor];
            } else {
                imageView.backgroundColor = kBackgroundColorWhiteDark;
                imageView.contentMode = UIViewContentModeCenter;
                imageView.image = [UIImage imageNamed:@"topic_placeholder"];
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageModel.imageQuote.identifier] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    @strongify(self);
                    if (cacheType == SDImageCacheTypeNone && self.reloadCellBlock && finished) {
                        imageView.image = nil;
                        self.reloadCellBlock();
                    }
                }] ;
                
            }
            offsetY += (imageView.height + 7);
            UIButton *button = self.imageButtonArray[imageIndex];
            button.frame = imageView.frame;
            
            NSUInteger imageIndexNoneBlock = imageIndex;
            
            [button bk_removeAllBlockObservers];
            [button bk_whenTapped:^{
                @strongify(self);
                NSArray *photos = [IDMPhoto photosWithURLs:self.model.imageURLs];
                IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos animatedFromView:imageView];
                browser.delegate = self;
                browser.displayActionButton = NO;
                browser.displayArrowButton = NO;
                browser.displayCounterLabel = YES;
                browser.dismissOnTouch = YES ;
                [browser setInitialPageIndex:imageIndexNoneBlock];
                [[AppDelegateInstance rootViewController] presentViewController:browser animated:YES completion:nil];
            }];
            imageIndex ++;
        }
    }];
}

#pragma mark - View Creator

- (UIImageView *)createImageView {
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = kBackgroundColorWhiteDark;
    imageView.contentMode = UIViewContentModeCenter;
    imageView.clipsToBounds = YES;
    [self addSubview:imageView];
    
    UIButton *button = [[UIButton alloc] init];
    button.clipsToBounds = YES ;
    [self addSubview:button];
    
    [self.imageButtonArray addObject:button];
    [self.imageArray addObject:imageView];
    
    return imageView;
}

- (TTTAttributedLabel *)createAttributedLabel {
    TTTAttributedLabel *attributedLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    attributedLabel.backgroundColor      = [UIColor clearColor];
    attributedLabel.textColor            = kFontColorBlackDark;
    attributedLabel.font                 = [UIFont systemFontOfSize:kContentFontSize];;
    attributedLabel.numberOfLines        = 0;
    attributedLabel.lineBreakMode        = NSLineBreakByWordWrapping;
    attributedLabel.delegate             = self;
    [self addSubview:attributedLabel];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6.0;
    
    attributedLabel.linkAttributes = @{
                                       NSForegroundColorAttributeName:kFontColorBlackBlue,
                                       NSFontAttributeName: [UIFont systemFontOfSize:kContentFontSize],
                                       NSParagraphStyleAttributeName: style
                                       };
    
    attributedLabel.activeLinkAttributes = @{
                                             (NSString *)kCTUnderlineStyleAttributeName: [NSNumber numberWithBool:NO],
                                             NSForegroundColorAttributeName: kBackgroundColorWhite,
                                             (NSString *)kTTTBackgroundFillColorAttributeName: (__bridge id)[kColorBlue CGColor],
                                             (NSString *)kTTTBackgroundCornerRadiusAttributeName:[NSNumber numberWithFloat:4.0f]
                                             };
    
    
    [self.attributedLabelArray addObject:attributedLabel];
    
    return attributedLabel;
}

#pragma mark - Notifications

- (void)didReceiveSelectMemberNotification:(NSNotification *)notification {
    self.selectedReplyModel = notification.object;
    [self setNeedsLayout];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    SIQuote *quote = [self quoteForIdentifier:url.absoluteString];
    self.longPressRecognizer.enabled = NO;
    if (quote) {
        if (quote.type == SIQuoteTypeUser) {
            V2Reply *replyModel;
            for (V2Reply *model in self.replyList) {
                if ([model.replyCreator.memberName isEqualToString:quote.identifier]) {
                    replyModel = model;
                    break;
                }
            }
            
            V2MemberViewController *profileVC = [[V2MemberViewController alloc] init];
            if (replyModel) {
                profileVC.member = replyModel.replyCreator;
            } else {
                profileVC.username = quote.identifier;
            }
            [self.navi pushViewController:profileVC animated:YES];
        }
        
        if (quote.type == SIQuoteTypeImage) {
            IDMPhoto *photo = [IDMPhoto photoWithURL:url];
            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:@[photo] animatedFromView:nil];
            browser.delegate = self;
            browser.displayActionButton = NO;
            browser.displayArrowButton = YES;
            browser.displayCounterLabel = YES;
            [[AppDelegateInstance rootViewController] presentViewController:browser animated:YES completion:nil];
        }
        
        if (quote.type == SIQuoteTypeTopic) {
            V2TopicViewController *topicVC = [[V2TopicViewController alloc] init];
            V2Topic *topicModel = [[V2Topic alloc] init];
            topicModel.topicId = quote.identifier;
            topicVC.model = topicModel;
            [self.navi pushViewController:topicVC animated:YES];
        }
        
        if (quote.type == SIQuoteTypeAppStore) {
            NSURL *URL = [NSURL URLWithString:quote.identifier];
            if ([[UIApplication sharedApplication] canOpenURL:URL]) {
                [[UIApplication sharedApplication] openURL:URL];
            }
        }
        
        if (quote.type == SIQuoteTypeEmail) {
            NSString *urlString = [NSString stringWithFormat:@"mailto:%@", quote.identifier];
            NSURL *URL = [NSURL URLWithString:urlString];
            if ([[UIApplication sharedApplication] canOpenURL:URL]) {
                [[UIApplication sharedApplication] openURL:URL];
            }
        }
        
        if (quote.type == SIQuoteTypeLink) {
            V2WebViewController *webVC = [[V2WebViewController alloc] init];
            webVC.url = quote.identifier;
            [self.navi pushViewController:webVC animated:YES];
        }
    }
}

- (SIQuote *)quoteForIdentifier:(NSString *)identifier {
    for (SIQuote *quote in self.model.quoteArray) {
        if ([quote.identifier isEqualToString:identifier]) {
            return quote;
        }
    }
    return nil;
}

#pragma mark - Class Methods
+ (CGFloat)getCellHeightWithReply:(V2Reply *)model {
    NSInteger titleHeight = [model.replyCreator.memberName heightForFont:[UIFont systemFontOfSize:kNameFontSize] width:kNameLabelWidth] ;
    __block NSInteger bodyHeight = 0;
    if (model.contentArray) {
        [model.contentArray enumerateObjectsUsingBlock:^(V2ContentBase *contentModel, NSUInteger idx, BOOL *stop) {
            if (contentModel.contentType == V2ContentTypeString) {
                V2ContentString *stringModel = (V2ContentString *)contentModel;
                bodyHeight += [TTTAttributedLabel sizeThatFitsAttributedString:stringModel.attributedString withConstraints:(CGSize){kContentLabelWidth, 0} limitedToNumberOfLines:0].height + 7;
            }
            if (contentModel.contentType == V2ContentTypeImage) {
                V2ContentImage *imageModel = (V2ContentImage *)contentModel;
                CGSize imageSize = [[self class] imageSizeForKey:imageModel.imageQuote.identifier];
                bodyHeight += (imageSize.height + 7);
            }
        }];
    } else {
        bodyHeight = [TTTAttributedLabel sizeThatFitsAttributedString:model.attributedString withConstraints:(CGSize){kContentLabelWidth, 0} limitedToNumberOfLines:0].height;
        bodyHeight += 8;
    }
    if (!model.replyContent.length) {
        return 1;
    }
    CGFloat cellHeight = 8*2 + titleHeight + bodyHeight;
    if (cellHeight < 60) {
        return 60;
    } else {
        return cellHeight;
    }
}

+ (CGSize)imageSizeForKey:(NSString *)key {
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    if (!cachedImage) {
        cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    }
    if (cachedImage) {
        return [cachedImage fitWidth:kContentLabelWidth];
    } else {
        return CGSizeMake(kContentLabelWidth, 60);
    }
}

+ (UIImage *)imageForKey:(NSString *)key {
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    if (!cachedImage) {
        cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    }
    return cachedImage;
}



@end
