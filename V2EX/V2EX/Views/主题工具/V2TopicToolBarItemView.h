//
//  V2TopicToolBarItemView.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/23.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ButtonPressedBlock)();

@interface V2TopicToolBarItemView : UIView

@property (nonatomic, copy) NSString           *itemTitle;
@property (nonatomic, strong) UIImage            *itemImage;
@property (nonatomic, copy) ButtonPressedBlock buttonPressedBlock;

@property (nonatomic, copy) UIColor *backgroundColorNormal;
@property (nonatomic, copy) UIColor *backgroundColorHighlighted;

@end
