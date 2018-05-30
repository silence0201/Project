//
//  V2CategoriesMenuView.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/21.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedIndexAction)(NSInteger index);
@interface V2CategoriesMenuView : UIView

@property (nonatomic, strong) NSArray *sectionTitleArray;
@property (nonatomic, assign, getter = isFavorite) BOOL favorite;
@property (nonatomic, copy) SelectedIndexAction selectedAction ;

@end
