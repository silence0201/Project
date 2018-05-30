//
//  V2MenuSectionView.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedIndexBlock)(NSInteger);

@interface V2MenuSectionView : UIView

@property (nonatomic,assign) NSInteger selectedIndex ;

@property (nonatomic,copy) SelectedIndexBlock didSelectedIndexBlock ;

@end
