//
//  V2TopicBodyCell.m
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/24.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "V2TopicBodyCell.h"

#import <IDMPhotoBrowser/IDMPhotoBrowser.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

#import "V2TopicViewController.h"
#import "V2WebViewController.h"
#import "V2MemberViewController.h"

#import "SIQuote.h"
#import "UIImage+Tint.h"

#import "AppDelegate.h"
#import "V2RootViewController.h"

static CGFloat const kBodyFontSize = 16.0f;

#define kBodyLabelWidth (kScreenWidth - 20)

@interface V2TopicBodyCell () <TTTAttributedLabelDelegate, IDMPhotoBrowserDelegate>

@property (nonatomic, strong) TTTAttributedLabel   *bodyLabel;

@property (nonatomic, strong) UIView    *borderLineView;

@property (nonatomic, assign) NSInteger bodyHeight;

@property (nonatomic, strong) NSMutableArray *attributedLabelArray;
@property (nonatomic, strong) NSMutableArray *imageArray;
@property (nonatomic, strong) NSMutableArray *imageButtonArray;
@property (nonatomic, strong) NSMutableArray *imageUrls;

@end

@implementation V2TopicBodyCell

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
        
        self.bodyLabel = [self createAttributedLabel];
        
        self.borderLineView = [UIView new];
        self.borderLineView.backgroundColor = kLineColorBlackDark;
        [self addSubview:self.borderLineView];
        
    }
    return self;
}

#pragma mark - View Creator

- (UIImageView *)createImageView {
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = kBackgroundColorWhiteDark;
    imageView.contentMode = UIViewContentModeCenter;
    imageView.clipsToBounds = YES;
    [self addSubview:imageView];
    
    UIButton *button = [[UIButton alloc] init];
    [self addSubview:button];
    
    [self.imageButtonArray addObject:button];
    [self.imageArray addObject:imageView];
    
    return imageView;
}

- (TTTAttributedLabel *)createAttributedLabel {
    
    TTTAttributedLabel *attributedLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    attributedLabel.backgroundColor      = [UIColor clearColor];
    attributedLabel.textColor            = kFontColorBlackDark;
    attributedLabel.font                 = [UIFont systemFontOfSize:kBodyFontSize];;
    attributedLabel.numberOfLines        = 0;
    attributedLabel.lineBreakMode        = NSLineBreakByWordWrapping;
    attributedLabel.delegate             = self;
    [self addSubview:attributedLabel];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 8.0;
    attributedLabel.linkAttributes = @{
                                       NSForegroundColorAttributeName:kFontColorBlackBlue,
                                       NSFontAttributeName: [UIFont systemFontOfSize:kBodyFontSize],
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

#pragma mark - TTTAttributedLabelDelegate
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    SIQuote *quote = [self quoteForIdentifier:url.absoluteString];
    if (quote) {
        if (quote.type == SIQuoteTypeUser) {
            V2MemberViewController *profileVC = [[V2MemberViewController alloc] init];
            profileVC.username = quote.identifier;
            [self.navi pushViewController:profileVC animated:YES];
        }
        
        if (quote.type == SIQuoteTypeImage) {
            IDMPhoto *photo = [IDMPhoto photoWithURL:url] ;
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

- (void)layoutSubviews {
    [super layoutSubviews];
    self.borderLineView.frame = (CGRect){10, self.height - 0.5, kScreenWidth - 20, 0.5};
    [self layoutContent];
}

- (void)layoutContent {
    if (!self.model.contentArray) {
        self.bodyLabel.attributedText = self.model.attributedString;
        self.bodyHeight = [TTTAttributedLabel sizeThatFitsAttributedString:self.model.attributedString withConstraints:(CGSize){kBodyLabelWidth, 0} limitedToNumberOfLines:0].height;
        if (!self.bodyLabel.attributedText.length) {
            self.bodyHeight = 0;
        }
        self.bodyLabel.frame      = CGRectMake(10, 5, kBodyLabelWidth, self.bodyHeight);
        for (SIQuote *quote in self.model.quoteArray) {
            [self.bodyLabel addLinkToURL:[NSURL URLWithString:quote.identifier] withRange:quote.range];
        }
    } else {
        __block NSUInteger labelIndex = 0;
        __block NSUInteger imageIndex = 0;
        __block CGFloat offsetY = 10;
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
                CGFloat labelHeight = [TTTAttributedLabel sizeThatFitsAttributedString:stringModel.attributedString withConstraints:(CGSize){kBodyLabelWidth, 0} limitedToNumberOfLines:0].height;
                if (stringModel.attributedString.length == 0) {
                    labelHeight = 0;
                }
                label.size = (CGSize){kBodyLabelWidth, labelHeight};
                label.origin = (CGPoint){10, offsetY};
                
                for (SIQuote *quote in stringModel.quoteArray) {
                    if (stringModel.attributedString.length >= quote.range.location + quote.range.length) {
                        [label addLinkToURL:[NSURL URLWithString:quote.identifier] withRange:quote.range];
                    }
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
                imageView.origin = (CGPoint){10, offsetY};
                
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
    
}

+ (CGSize)imageSizeForKey:(NSString *)key {
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    if (!cachedImage) {
        cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    }
    if (cachedImage) {
        return [cachedImage fitWidth:kBodyLabelWidth];
    } else {
        return CGSizeMake(kBodyLabelWidth, 60);
    }
}

+ (UIImage *)imageForKey:(NSString *)key {
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    if (!cachedImage) {
        cachedImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    }
    return cachedImage;
}

- (void)setModel:(V2Topic *)model{
    _model = model ;
}

#pragma mark - Class Methods
+ (CGFloat)getCellHeightWithTopic:(V2Topic *)model {
    __block NSInteger bodyHeight = 0;
    if (model.contentArray) {
        [model.contentArray enumerateObjectsUsingBlock:^(V2ContentBase *contentModel, NSUInteger idx, BOOL *stop) {
            if (contentModel.contentType == V2ContentTypeString) {
                V2ContentString *stringModel = (V2ContentString *)contentModel;
                bodyHeight += [TTTAttributedLabel sizeThatFitsAttributedString:stringModel.attributedString withConstraints:(CGSize){kBodyLabelWidth, 0} limitedToNumberOfLines:0].height + 7;
            }
            if (contentModel.contentType == V2ContentTypeImage) {
                V2ContentImage *imageModel = (V2ContentImage *)contentModel;
                CGSize imageSize = [[self class] imageSizeForKey:imageModel.imageQuote.identifier];
                bodyHeight += (imageSize.height + 7);
            }
        }];
    } else {
        bodyHeight = [TTTAttributedLabel sizeThatFitsAttributedString:model.attributedString withConstraints:(CGSize){kBodyLabelWidth, 0} limitedToNumberOfLines:0].height;
    }
    
    if (!model.topicContent.length) {
        return 1;
    }
    return bodyHeight + 15;
}



@end
