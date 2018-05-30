//
//  V2Node.h
//  V2EX
//
//  Created by 杨晴贺 on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2BaseEntity.h"

@interface V2Node : V2BaseEntity

@property (nonatomic,copy) NSString *nodeId;
@property (nonatomic,copy) NSString *nodeName;
@property (nonatomic,copy) NSString *nodeUrl;
@property (nonatomic,copy) NSString *nodeTitle;
@property (nonatomic,copy) NSString *nodeTitleAlternative;
@property (nonatomic,copy) NSString *nodeTopicCount;
@property (nonatomic,copy) NSString *nodeHeader;
@property (nonatomic,copy) NSString *nodeFooter;
@property (nonatomic,copy) NSString *nodeCreated;

@end


