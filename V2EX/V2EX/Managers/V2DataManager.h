//
//  V2DataManager.h
//  V2EX
//
//  Created by Silence on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2BaseManager.h"
#import "V2Node.h"
#import "V2Topic.h"
#import "V2Member.h"
#import "V2User.h"
#import "V2Notification.h"
#import "V2Reply.h"
#import "V2MemberReply.h"

typedef NS_ENUM(NSInteger, V2ErrorType) {
    V2ErrorTypeNoOnceAndNext          = 700,
    V2ErrorTypeLoginFailure           = 701,
    V2ErrorTypeRequestFailure         = 702,
    V2ErrorTypeGetFeedURLFailure      = 703,
    V2ErrorTypeGetTopicListFailure    = 704,
    V2ErrorTypeGetNotificationFailure = 705,
    V2ErrorTypeGetFavUrlFailure       = 706,
    V2ErrorTypeGetMemberReplyFailure  = 707,
    V2ErrorTypeGetTopicTokenFailure   = 708,
    V2ErrorTypeGetCheckInURLFailure   = 709,
};

typedef NS_ENUM (NSInteger, V2HotNodesType) {
    V2HotNodesTypeTech,
    V2HotNodesTypeCreative,
    V2HotNodesTypePlay,
    V2HotNodesTypeApple,
    V2HotNodesTypeJobs,
    V2HotNodesTypeDeals,
    V2HotNodesTypeCity,
    V2HotNodesTypeQna,
    V2HotNodesTypeHot,
    V2HotNodesTypeAll,
    V2HotNodesTypeR2,
    V2HotNodesTypeNodes,
    V2HotNodesTypeMembers,
    V2HotNodesTypeFav,
};

@interface V2DataManager : V2BaseManager

@property (nonatomic, strong) V2User *user;

#pragma mark - GET
/// 获取所有节点的信息
- (NSURLSessionDataTask *)getAllNodesSuccess:(void (^)(NSArray<V2Node *> *list))success
                                     failure:(void (^)(NSError *error))failure;

/// 根绝id或者名字获取节点信息
- (NSURLSessionDataTask *)getNodeWithId:(NSString *)nodeId
                                   name:(NSString *)name
                                success:(void (^)(V2Node *model))success
                                failure:(void (^)(NSError *error))failure;

/// 获取某个节点的TopicList
- (NSURLSessionDataTask *)getTopicListWithNodeId:(NSString *)nodeId
                                        nodename:(NSString *)name
                                        username:(NSString *)username
                                            page:(NSInteger)page
                                         success:(void (^)(NSArray<V2Topic *> *list))success
                                         failure:(void (^)(NSError *error))failure;

/// 获取Last的内容,相当于首页的“全部”这个 tab 下的最新内容
- (NSURLSessionDataTask *)getTopicListLatestSuccess:(void (^)(NSArray<V2Topic *> *list))success
                                            failure:(void (^)(NSError *error))failure ;


/// 这个必须登录才能获取相应的信息
- (NSURLSessionDataTask *)getTopicListRecentWithPage:(NSInteger)page
                                              Success:(void (^)(NSArray<V2Topic *> *list))success
                                              failure:(void (^)(NSError *error))failure;

/// 获取某种类型的TopicList,解析html页面
- (NSURLSessionDataTask *)getTopicListWithType:(V2HotNodesType)type
                                       Success:(void (^)(NSArray<V2Topic *> *list))success
                                       failure:(void (^)(NSError *error))failure;

/// 根据id获取Topic信息
- (NSURLSessionDataTask *)getTopicWithTopicId:(NSString *)topicId
                                      success:(void (^)(V2Topic *model))success
                                      failure:(void (^)(NSError *error))failure;

/// 根据topicId,获取回复的列表
- (NSURLSessionDataTask *)getReplyListWithTopicId:(NSString *)topicId
                                          success:(void (^)(NSArray<V2Reply *> *list))success
                                          failure:(void (^)(NSError *error))failure;

/// 根据id或者name获取用户的信息
- (NSURLSessionDataTask *)getMemberProfileWithUserId:(NSString *)userid
                                            username:(NSString *)username
                                             success:(void (^)(V2Member *member))success
                                             failure:(void (^)(NSError *error))failure;

/// 获取指定会员的发布的主题
- (NSURLSessionDataTask *)getMemberTopicListWithMember:(V2Member *)model
                                                       page:(NSInteger)page
                                                    Success:(void (^)(NSArray<V2Topic *> *list))success
                                                    failure:(void (^)(NSError *error))failure;

/// 获取当前用户关注的NodeList,返回类型为name何title为key的字典
- (NSURLSessionDataTask *)getMemberNodeListSuccess:(void (^)(NSArray *list))success
                                           failure:(void (^)(NSError *error))failure;

#pragma mark - Action
/// 收藏某个节点
- (NSURLSessionDataTask *)favNodeWithName:(NSString *)nodeName
                                  success:(void (^)(NSString *message))success
                                  failure:(void (^)(NSError *error))failure;

/// 根据主题id收藏某个主题
- (NSURLSessionDataTask *)favTopicWithTopicId:(NSString *)topicId
                                      success:(void (^)(NSString *message))success
                                      failure:(void (^)(NSError *error))failure;

/// 根据主题id取消收藏某个主题
- (NSURLSessionDataTask *)unfavTopicWithTopicId:(NSString *)topicId
                                      success:(void (^)(NSString *message))success
                                      failure:(void (^)(NSError *error))failure;

/// 根据主题id感谢某个主题
- (NSURLSessionDataTask *)thankTopicWithTopicId:(NSString *)topicId
                                        success:(void (^)(NSString *message))success
                                        failure:(void (^)(NSError *error))failure;

/// 根据主题id忽略某个主题
- (NSURLSessionDataTask *)ignoreTopicWithTopicId:(NSString *)topicId
                                        success:(void (^)(NSString *message))success
                                        failure:(void (^)(NSError *error))failure;

/// 根绝主题id以及对应的Token收藏主题
- (NSURLSessionDataTask *)topicFavWithTopicId:(NSString *)topicId
                                        token:(NSString *)token
                                      success:(void (^)(NSString *message))success
                                      failure:(void (^)(NSError *error))failure;
/// 根绝主题id以及对应的Token取消收藏主题
- (NSURLSessionDataTask *)topicFavCancelWithTopicId:(NSString *)topicId
                                              token:(NSString *)token
                                            success:(void (^)(NSString *message))success
                                            failure:(void (^)(NSError *error))failure;
/// 根绝主题id以及对应的Token取消收藏主题
- (NSURLSessionDataTask *)topicThankWithTopicId:(NSString *)topicId
                                          token:(NSString *)token
                                        success:(void (^)(NSString *message))success
                                        failure:(void (^)(NSError *error))failure;
/// 根绝回复id以及主题的Token取消收藏主题
- (NSURLSessionDataTask *)replyThankWithReplyId:(NSString *)replyId
                                          token:(NSString *)token
                                        success:(void (^)(NSString *message))success
                                        failure:(void (^)(NSError *error))failure;
/// 根据会员名关注该会员
- (NSURLSessionDataTask *)memberFollowWithMemberName:(NSString *)memberName
                                             success:(void (^)(NSString *message))success
                                             failure:(void (^)(NSError *error))failure;
/// 根据会员名屏蔽该会员
- (NSURLSessionDataTask *)memberBlockWithMemberName:(NSString *)memberName
                                            success:(void (^)(NSString *message))success
                                            failure:(void (^)(NSError *error))failure;


#pragma mark - Token
/// 根据TopicId获取对应的Token
- (NSURLSessionDataTask *)getTopicTokenWithTopicId:(NSString *)topicId
                                           success:(void (^)(NSString *token))success
                                           failure:(void (^)(NSError *error))failure;



#pragma mark - Create
/// 根据topicId创建回复
- (NSURLSessionDataTask *)replyCreateWithTopicId:(NSString *)topicId
                                         content:(NSString *)content
                                         success:(void (^)(NSString *message))success
                                         failure:(void (^)(NSError *error))failure;
/// 创建主题
- (NSURLSessionDataTask *)topicCreateWithNodeName:(NSString *)nodeName
                                            title:(NSString *)title
                                          content:(NSString *)content
                                          success:(void (^)(NSString *message))success
                                          failure:(void (^)(NSError *error))failure;


#pragma mark - Login & Profile
/// 用户登录
- (NSURLSessionDataTask *)userLoginWithUsername:(NSString *)username password:(NSString *)password
                                        success:(void (^)(NSString *message))success
                                        failure:(void (^)(NSError *error))failure;

/// 用户退出
- (void)UserLogout;

/// 获取用户的Feed地址
- (NSURLSessionDataTask *)getFeedURLSuccess:(void (^)(NSURL *feedURL))success
                                    failure:(void (^)(NSError *error))failure;
#pragma mark - Notifications
/// 获取用户通知信息
- (NSURLSessionDataTask *)getUserNotificationWithPage:(NSInteger)page
                                              success:(void (^)(NSArray<V2Notification *> *list))success
                                              failure:(void (^)(NSError *error))failure;
/// 获取用户的回复信息
- (NSURLSessionDataTask *)getUserReplyWithUsername:(NSString *)username
                                              page:(NSInteger)page
                                           success:(void (^)(NSArray<V2MemberReply *> *list))success
                                           failure:(void (^)(NSError *error))failure;

#pragma mark - CheckIn
/// 获取签到地址
- (NSURLSessionDataTask *)getCheckInURLSuccess:(void (^)(NSURL *URL))success
                                       failure:(void (^)(NSError *error))failure;


/// 根据签到地址进行签到
- (NSURLSessionDataTask *)checkInWithURL:(NSURL *)url
                                 Success:(void (^)(NSInteger count))success
                                 failure:(void (^)(NSError *error))failure;
/// 获取签到的天数
- (NSURLSessionDataTask *)getCheckInCountSuccess:(void (^)(NSInteger count))success
                                         failure:(void (^)(NSError *error))failure;

@end
