//
//  V2TopicStateManager.h
//  V2EX
//
//  Created by Silence on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2BaseManager.h"
#import "V2Topic.h"

@interface V2TopicStateManager : V2BaseManager

- (V2TopicState)getTopicStateWithTopicModel:(V2Topic *)model;
- (BOOL)saveStateForTopicModel:(V2Topic *)model;

@end
