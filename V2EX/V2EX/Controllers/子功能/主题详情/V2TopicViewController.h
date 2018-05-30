//
//  V2TopicViewController.h
//  V2EX
//
//  Created by 杨晴贺 on 2017/3/21.
//  Copyright © 2017年 Silence. All rights reserved.
//

#import "SIRefreshControl.h"

@interface V2TopicViewController : SIRefreshControl

@property (nonatomic, assign, getter = isCreate) BOOL create;
@property (nonatomic, assign, getter = isPreview) BOOL preview;

@property (nonatomic, strong) V2Topic *model;

@end
