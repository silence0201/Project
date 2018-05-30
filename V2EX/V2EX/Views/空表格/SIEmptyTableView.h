//
//  SIEmptyTableView.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/20.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^EmptyClickAction)();
@interface SIEmptyTableView : UITableView

@property (nonatomic,copy) EmptyClickAction emptyClickAction ;

@property (nonatomic,copy) NSString *title ;
@property (nonatomic,copy) NSString *buttonTitle ;

@property (nonatomic, getter=isLoading) BOOL loading;

@end
