//
//  SIMetionTextView.h
//  V2EX
//
//  Created by Silence on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIQuote.h"

@interface SIMetionTextView : UITextView

@property (nonatomic, copy) UIColor *textBackgroundColor;

@property (nonatomic, readonly) UILabel *placeHolderLabel;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, strong) UIColor *placeholderColor;

@property (nonatomic, copy) BOOL (^textViewShouldBeginEditingBlock)(UITextView *textView);
@property (nonatomic, copy) BOOL (^textViewShouldChangeBlock)(UITextView *textView, NSString *text);
@property (nonatomic, copy) void (^textViewDidChangeBlock)(UITextView *textView);

@property (nonatomic, copy) void (^textViewDidAddQuoteSuccessBlock)();

@property (nonatomic, copy) NSString *renderedString;

- (void)addQuote:(SIQuote *)quote;
- (void)setNeedsRefreshQuotes;
- (void)removeAllQuotes;

@end
