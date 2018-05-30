//
//  V2User.h
//  V2EX
//
//  Created by 杨晴贺 on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//


@interface V2User : V2BaseEntity

@property (nonatomic, strong) V2Member *member;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSURL *feedURL;
@property (nonatomic, assign, getter = isLogin) BOOL login;

@end
