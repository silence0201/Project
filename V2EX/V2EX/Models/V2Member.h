//
//  V2Member.h
//  V2EX
//
//  Created by 杨晴贺 on 22/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//


@interface V2Member : V2BaseEntity

@property (nonatomic,copy) NSString *memberId;
@property (nonatomic,copy) NSString *memberName;
@property (nonatomic,copy) NSString *memberTagline;
@property (nonatomic,copy) NSString *memberBio;
@property (nonatomic,copy) NSString *memberCreated;
@property (nonatomic,copy) NSString *memberLocation;
@property (nonatomic,copy) NSString *memberStatus;
@property (nonatomic,copy) NSString *memberTwitter;
@property (nonatomic,copy) NSString *memberUrl;
@property (nonatomic,copy) NSString *memberWebsite;
@property (nonatomic,copy) NSString *memberPsn ;
@property (nonatomic,copy) NSString *memberGithub ;
@property (nonatomic,copy) NSString *memberBtc ;
@property (nonatomic,copy) NSString *memberAvatarMini;
@property (nonatomic,copy) NSString *memberAvatarNormal;
@property (nonatomic,copy) NSString *memberAvatarLarge;

@end
