//
//  V2TopicStateManager.h
//  V2EX
//
//  Created by 杨晴贺 on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//


@interface V2TopicStateManager : V2BaseManager

/// 获取Topic的状态
- (V2TopicState)getTopicStateWithTopicModel:(V2Topic *)model;

/// 保存Topic的状态
- (BOOL)saveStateForTopicModel:(V2Topic *)model;

@end
