//
//  V2DataManager.m
//  V2EX
//
//  Created by Silence on 23/01/2017.
//  Copyright © 2017 Silence. All rights reserved.
//

#import "V2DataManager.h"
#import <AFNetworking/AFNetworking.h>
#import <YYCategories/YYCategories.h>
#import <FXKeychain/FXKeychain.h>
#import <SIHTMLParser/HTMLParser.h>
#import <RegexKitLite/RegexKitLite.h>
#import <CoreText/CoreText.h>
#import "Macro.h"
#import "Const.h"
#import "V2CheckInManager.h"


static NSString *const kOnceString =  @"once";
static NSString *const kNextString =  @"next";

static NSString *const kUsername = @"username";
static NSString *const kUserid = @"userid";
static NSString *const kAvatarURL = @"avatarURL";
static NSString *const kUserIsLogin = @"userIsLogin";

static NSString *const kLoginPassword = @"p";
static NSString *const kLoginUsername = @"u";

typedef NS_ENUM(NSInteger, V2RequestMethod) {
    V2RequestMethodJSONGET    = 1,
    V2RequestMethodHTTPPOST   = 2,
    V2RequestMethodHTTPGET    = 3,
    V2RequestMethodHTTPGETPC  = 4
};

@interface V2DataManager ()


@property (nonatomic, strong) AFHTTPSessionManager *manager;

@property (nonatomic, copy) NSString *userAgentMobile;
@property (nonatomic, copy) NSString *userAgentPC;

@end


@implementation V2DataManager

- (instancetype)init {
    if (self = [super init]) {
        UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectZero];
        self.userAgentMobile = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        self.userAgentPC = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_2) AppleWebKit/602.3.12 (KHTML, like Gecko) Version/10.0.2 Safari/602.3.12";
        NSURL  *baseUrl = [NSURL URLWithString:@"https://www.v2ex.com"];
        self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
        AFHTTPRequestSerializer* serializer = [AFHTTPRequestSerializer serializer];
        self.manager.requestSerializer = serializer;
        BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserIsLogin] boolValue];
        if (isLogin) {
            V2User *user = [[V2User alloc] init];
            user.login = YES;
            V2Member *member = [[V2Member alloc] init];
            user.member = member;
            user.member.memberName = [[NSUserDefaults standardUserDefaults] objectForKey:kUsername];
            user.member.memberId = [[NSUserDefaults standardUserDefaults] objectForKey:kUserid];
            user.member.memberAvatarLarge = [[NSUserDefaults standardUserDefaults] objectForKey:kAvatarURL];
            _user = user;
        }
        
    }
    return self;
}


- (void)setUser:(V2User *)user {
    _user = user;
    if (user) {
        self.user.login = YES;
        [[NSUserDefaults standardUserDefaults] setObject:user.member.memberName forKey:kUsername];
        [[NSUserDefaults standardUserDefaults] setObject:user.member.memberId forKey:kUserid];
        [[NSUserDefaults standardUserDefaults] setObject:user.member.memberAvatarLarge forKey:kAvatarURL];
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:kUserIsLogin];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUsername];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserid];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kAvatarURL];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserIsLogin];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

+ (instancetype)manager {
    static V2DataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[V2DataManager alloc] init];
    });
    return manager;
}

- (NSURLSessionDataTask *)requestWithMethod:(V2RequestMethod)method
                                  URLString:(NSString *)URLString
                                 parameters:(NSDictionary *)parameters
                                    success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                                    failure:(void (^)(NSError *error))failure  {
    // stateBar
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    // Handle Common Mission, Cache, Data Reading & etc.
    void (^responseHandleBlock)(NSURLSessionDataTask *task, id responseObject) = ^(NSURLSessionDataTask *task, id responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        success(task, responseObject);
        
    };
    
    // Create HTTPSession
    NSURLSessionDataTask *task = nil;
    [self.manager.requestSerializer setValue:self.userAgentMobile forHTTPHeaderField:@"User-Agent"];
    
    
    if (method == V2RequestMethodJSONGET) {
        AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        self.manager.responseSerializer = responseSerializer;
        task = [self.manager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            responseHandleBlock(task, responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            failure(error);
        }];
    }
    if (method == V2RequestMethodHTTPGET) {
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        self.manager.responseSerializer = responseSerializer;
        task = [self.manager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            responseHandleBlock(task, responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            failure(error);
        }];
    }
    if (method == V2RequestMethodHTTPPOST) {
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        self.manager.responseSerializer = responseSerializer;
        task = [self.manager POST:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            responseHandleBlock(task, responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            failure(error);
        }];
    }
    if (method == V2RequestMethodHTTPGETPC) {
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
        self.manager.responseSerializer = responseSerializer;
        [self.manager.requestSerializer setValue:self.userAgentPC forHTTPHeaderField:@"User-Agent"];
        task = [self.manager GET:URLString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            responseHandleBlock(task, responseObject);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            failure(error);
        }];
    }
    
    return task;
}

#pragma mark - Public Request Methods - GET
- (NSURLSessionDataTask *)getAllNodesSuccess:(void (^)(NSArray<V2Node *> *list))success
                                     failure:(void (^)(NSError *error))failure {
    
    return [self requestWithMethod:V2RequestMethodJSONGET URLString:@"/api/nodes/all.json" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *list = [NSArray yy_modelArrayWithClass:[V2Node class] json:responseObject] ;
        success(list);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSURLSessionDataTask *)getNodeWithId:(NSString *)nodeId
                                   name:(NSString *)name
                                success:(void (^)(V2Node *model))success
                                failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (nodeId) {
        [parameters setValue:nodeId forKey:@"id"] ;
    }
    if (name) {
        [parameters setValue:name forKey:@"name"] ;
    }
    
    return [self requestWithMethod:V2RequestMethodJSONGET URLString:@"/api/nodes/show.json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        V2Node *model = [V2Node yy_modelWithJSON:responseObject] ;
        success(model);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSURLSessionDataTask *)getTopicListWithNodeId:(NSString *)nodeId
                                        nodename:(NSString *)name
                                        username:(NSString *)username
                                            page:(NSInteger)page
                                         success:(void (^)(NSArray<V2Topic *> *list))success
                                         failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (nodeId) {
        [parameters setValue:nodeId forKey:@"node_id"] ;
        [parameters setValue:@(page) forKey:@"p"] ;
    }
    if (name) {
        [parameters setValue:name forKey:@"node_name"] ;
        [parameters setValue:@(page) forKey:@"p"] ;
    }
    if (username) {
        [parameters setValue:username forKey:@"username"] ;
        [parameters setValue:@(page) forKey:@"p"] ;
    }
    
    return [self requestWithMethod:V2RequestMethodJSONGET URLString:@"/api/topics/show.json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray<V2Topic *> *list= [NSArray yy_modelArrayWithClass:[V2Topic class] json:responseObject] ;
        success(list);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSURLSessionDataTask *)getTopicListLatestSuccess:(void (^)(NSArray<V2Topic *> *list))success
                                             failure:(void (^)(NSError *error))failure{
    return [self requestWithMethod:V2RequestMethodJSONGET URLString:@"/api/topics/latest.json" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray<V2Topic *> *list= [NSArray yy_modelArrayWithClass:[V2Topic class] json:responseObject] ;
        success(list) ;
    } failure:^(NSError *error) {
        failure(error) ;
    }];
}

- (NSURLSessionDataTask *)getTopicListRecentWithPage:(NSInteger)page
                                             Success:(void (^)(NSArray<V2Topic *> *list))success
                                             failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (page) {
        [parameters setValue:@(page) forKey:@"p"] ;
    }
    
    return [self requestWithMethod:V2RequestMethodHTTPGET URLString:@"/recent" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray<V2Topic *> *list = [V2Topic getTopicListFromResponseObject:responseObject];
        if (list) {
            success(list);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetTopicListFailure userInfo:nil];
            failure(error);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSURLSessionDataTask *)getTopicListWithType:(V2HotNodesType)type
                                       Success:(void (^)(NSArray<V2Topic *> *list))success
                                       failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary] ;
    switch (type) {
        case V2HotNodesTypeTech:
            [parameters setObject:@"tech" forKey:@"tab"];
            break;
        case V2HotNodesTypeCreative:
            [parameters setObject:@"creative" forKey:@"tab"];
            break;
        case V2HotNodesTypePlay:
            [parameters setObject:@"play" forKey:@"tab"];
            break;
        case V2HotNodesTypeApple:
            [parameters setObject:@"apple" forKey:@"tab"];
            break;
        case V2HotNodesTypeJobs:
            [parameters setObject:@"jobs" forKey:@"tab"];
            break;
        case V2HotNodesTypeDeals:
            [parameters setObject:@"deals" forKey:@"tab"];
            break;
        case V2HotNodesTypeCity:
            [parameters setObject:@"city" forKey:@"tab"];
            break;
        case V2HotNodesTypeQna:
            [parameters setObject:@"qna" forKey:@"tab"];
            break;
        case V2HotNodesTypeHot:
            [parameters setObject:@"hot" forKey:@"tab"];
            break;
        case V2HotNodesTypeAll:
            [parameters setObject:@"all" forKey:@"tab"];
            break;
        case V2HotNodesTypeR2:
            [parameters setObject:@"r2" forKey:@"tab"];
            break;
        case V2HotNodesTypeNodes:
            [parameters setObject:@"nodes" forKey:@"tab"];
            break;
        case V2HotNodesTypeMembers:
            [parameters setObject:@"members" forKey:@"tab"];
            break;
        default:
            [parameters setObject:@"all" forKey:@"tab"];
            break;
    }
    
    return [self requestWithMethod:V2RequestMethodHTTPGET URLString:@"" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray<V2Topic *> *list = [V2Topic getTopicListFromResponseObject:responseObject];
        if (list) {
            success(list);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetTopicListFailure userInfo:nil];
            failure(error);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSURLSessionDataTask *)getTopicWithTopicId:(NSString *)topicId
                                      success:(void (^)(V2Topic *model))success
                                      failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (topicId) {
        [parameters setValue:topicId forKey:@"id"] ;
    }
    return [self requestWithMethod:V2RequestMethodJSONGET URLString:@"/api/topics/show.json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        V2Topic *model = [V2Topic yy_modelWithJSON:[responseObject firstObject]] ;
        success(model);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSURLSessionDataTask *)getReplyListWithTopicId:(NSString *)topicId
                                          success:(void (^)(NSArray<V2Reply *> *list))success
                                          failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (topicId) {
        [parameters setValue:topicId forKey:@"topic_id"] ;
    }
    return [self requestWithMethod:V2RequestMethodJSONGET URLString:@"/api/replies/show.json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray<V2Reply *> *list = [NSArray yy_modelArrayWithClass:[V2Reply class] json:responseObject] ;
        success(list);
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSURLSessionDataTask *)getMemberProfileWithUserId:(NSString *)userid
                                            username:(NSString *)username
                                             success:(void (^)(V2Member *member))success
                                             failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary] ;
    if (userid) {
        [parameters setValue:userid forKey:@"id"] ;
    }
    if (username) {
        [parameters setValue:username forKey:@"username"] ;
    }
    
    return [self requestWithMethod:V2RequestMethodJSONGET URLString:@"/api/members/show.json" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            V2Member *member = [V2Member yy_modelWithJSON:responseObject] ;
            success(member);
        } else {
            failure(nil);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}


- (NSURLSessionDataTask *)getMemberTopicListWithMember:(V2Member *)model
                                                   page:(NSInteger)page
                                                Success:(void (^)(NSArray<V2Topic *> *list))success
                                                failure:(void (^)(NSError *error))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"member/%@/topics", model.memberName];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary] ;
    if (page) {
        [parameters setValue:@(page) forKey:@"p"] ;
    }
    return [self requestWithMethod:V2RequestMethodHTTPGET URLString:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray<V2Topic *> *list = [V2Topic getTopicListFromResponseObject:responseObject];
        for (V2Topic *topicModel in list) {
            topicModel.topicCreator = model;
        }
        if (list) {
            success(list);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetTopicListFailure userInfo:nil];
            failure(error);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSURLSessionDataTask *)getMemberNodeListSuccess:(void (^)(NSArray *list))success
                                           failure:(void (^)(NSError *error))failure {
    NSString *urlString = @"my/nodes";
    [self requestWithMethod:V2RequestMethodHTTPGET URLString:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *list = [self getNodeListFromResponseObject:responseObject];
        if (list) {
            success(list);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetTopicListFailure userInfo:nil];
            failure(error);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    return nil;
}

#pragma mark - Public Request Methods - Action

- (NSURLSessionDataTask *)favNodeWithName:(NSString *)nodeName
                                  success:(void (^)(NSString *message))success
                                  failure:(void (^)(NSError *error))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"/go/%@", nodeName];
    
    [self requestFavUrlWithURLString:urlString success:^(NSString *urlString) {
        
        //https://www.v2ex.com/unfavorite/node/22?once=42216
        if ([urlString rangeOfString:@"unfavorite"].location == NSNotFound) {
            [self requestWithMethod:V2RequestMethodHTTPGETPC URLString:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                success(@"fav success.");
            } failure:^(NSError *error) {
                failure(error);
            }];
        } else {
            success(@"fav success.");
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return nil;
}

- (NSURLSessionDataTask *)favTopicWithTopicId:(NSString *)topicId
                                      success:(void (^)(NSString *message))success
                                      failure:(void (^)(NSError *error))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"/t/%@", topicId];
    [self requestFavUrlWithURLString:urlString success:^(NSString *urlString) {
        //http://www.v2ex.com/unfavorite/node/10?t=1332044729
        if ([urlString rangeOfString:@"unfavorite"].location == NSNotFound) {
            [self requestWithMethod:V2RequestMethodHTTPGET URLString:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                success(@"fav success.");
            } failure:^(NSError *error) {
                failure(error);
            }];
        } else {
            success(@"fav success.");
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return nil;
}

- (NSURLSessionDataTask *)unfavTopicWithTopicId:(NSString *)topicId
                                        success:(void (^)(NSString *message))success
                                        failure:(void (^)(NSError *error))failure{
    return [self getTopicTokenWithTopicId:topicId success:^(NSString *token) {
        [self topicFavCancelWithTopicId:topicId token:token success:^(NSString *message) {
            success(message) ;
        } failure:^(NSError *error) {
            failure(error) ;
        }] ;
    } failure:^(NSError *error) {
        failure(error) ;
    }] ;
}

- (NSURLSessionDataTask *)thankTopicWithTopicId:(NSString *)topicId
                                        success:(void (^)(NSString *message))success
                                        failure:(void (^)(NSError *error))failure{
    return [self getTopicTokenWithTopicId:topicId success:^(NSString *token) {
        [self topicThankWithTopicId:topicId token:token success:^(NSString *message) {
            success(message) ;
        } failure:^(NSError *error) {
            failure(error) ;
        }] ;
    } failure:^(NSError *error) {
        failure(error) ;
    }] ;
}


- (NSURLSessionDataTask *)topicFavWithTopicId:(NSString *)topicId
                                        token:(NSString *)token
                                      success:(void (^)(NSString *message))success
                                      failure:(void (^)(NSError *error))failure {
    
    if (!token) {
        NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetTopicTokenFailure userInfo:nil];
        failure(error);
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"/favorite/topic/%@?t=%@", topicId, token];
    return [self requestWithMethod:V2RequestMethodHTTPGET URLString:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        success(@"fav success.");
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSURLSessionDataTask *)topicFavCancelWithTopicId:(NSString *)topicId
                                              token:(NSString *)token
                                            success:(void (^)(NSString *message))success
                                            failure:(void (^)(NSError *error))failure {
    if (!token) {
        NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetTopicTokenFailure userInfo:nil];
        failure(error);
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"/unfavorite/topic/%@?t=%@", topicId, token];
    return [self requestWithMethod:V2RequestMethodHTTPGET URLString:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        success(@"unfav success.");
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (NSURLSessionDataTask *)topicThankWithTopicId:(NSString *)topicId
                                          token:(NSString *)token
                                        success:(void (^)(NSString *message))success
                                        failure:(void (^)(NSError *error))failure {
    
    if (!token) {
        NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetTopicTokenFailure userInfo:nil];
        failure(error);
        return nil;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"/thank/topic/%@?t=%@", topicId, token];
    
    return [self requestWithMethod:V2RequestMethodHTTPPOST URLString:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        success(@"thank success.");
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}



- (NSURLSessionDataTask *)replyThankWithReplyId:(NSString *)replyId
                                          token:(NSString *)token
                                        success:(void (^)(NSString *message))success
                                        failure:(void (^)(NSError *error))failure {
    
    if (!token) {
        NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetTopicTokenFailure userInfo:nil];
        failure(error);
        return nil;
    }
    NSString *urlString = [NSString stringWithFormat:@"/thank/reply/%@?t=%@", replyId, token];
    return [self requestWithMethod:V2RequestMethodHTTPPOST URLString:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        success(@"thank success.");
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (NSURLSessionDataTask *)memberFollowWithMemberName:(NSString *)memberName
                                             success:(void (^)(NSString *message))success
                                             failure:(void (^)(NSError *error))failure {
    NSString *urlString = [NSString stringWithFormat:@"member/%@", memberName];
    [self.manager.requestSerializer setValue:urlString forHTTPHeaderField:@"Referer"];
    [self requestMemberTokenWithURLString:urlString success:^(NSString *tokenString) {
        NSString *followUrlString = [NSString stringWithFormat:@"/follow/%@", tokenString];
        [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"http://www.v2ex.com/member/%@", memberName] forHTTPHeaderField:@"Referer"];
        [self requestWithMethod:V2RequestMethodHTTPGET URLString:followUrlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            success(@"follow success");
        } failure:^(NSError *error) {
            failure(error);
        }];
    } failure:^(NSError *error) {
        failure(error);
    }];
    return nil;
}

- (NSURLSessionDataTask *)memberBlockWithMemberName:(NSString *)memberName
                                            success:(void (^)(NSString *message))success
                                            failure:(void (^)(NSError *error))failure {
    NSString *urlString = [NSString stringWithFormat:@"member/%@", memberName];
    [self.manager.requestSerializer setValue:urlString forHTTPHeaderField:@"Referer"];
    [self requestMemberTokenWithURLString:urlString success:^(NSString *tokenString) {
        NSString *blockUrlString = [NSString stringWithFormat:@"/block/%@", tokenString];
        [self.manager.requestSerializer setValue:[NSString stringWithFormat:@"http://www.v2ex.com/member/%@", memberName] forHTTPHeaderField:@"Referer"];
        [self requestWithMethod:V2RequestMethodHTTPGET URLString:blockUrlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            success(nil);
        } failure:^(NSError *error) {
            failure(error);
        }];
    } failure:^(NSError *error) {
        failure(error);
    }];
    return nil;
}

#pragma mark - Public Request Methods - Create
- (NSURLSessionDataTask *)replyCreateWithTopicId:(NSString *)topicId
                                         content:(NSString *)content
                                         success:(void (^)(NSString *message))success
                                         failure:(void (^)(NSError *error))failure {
    NSString *urlString = [NSString stringWithFormat:@"/t/%@", topicId];
    [self.manager.requestSerializer setValue:urlString forHTTPHeaderField:@"Referer"];
    [self requestOnceWithURLString:urlString success:^(NSString *onceString, id responseObject) {
        NSDictionary *parameters = @{kOnceString: onceString,
                                     @"content": content
                                     };
        [self requestWithMethod:V2RequestMethodHTTPPOST URLString:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            success(@"create success");
        } failure:^(NSError *error) {
            failure(error);
        }];
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return nil;
}

- (NSURLSessionDataTask *)topicCreateWithNodeName:(NSString *)nodeName
                                            title:(NSString *)title
                                          content:(NSString *)content
                                          success:(void (^)(NSString *message))success
                                          failure:(void (^)(NSError *error))failure {
    NSString *urlString = [NSString stringWithFormat:@"/new/%@", nodeName];
    [self requestOnceWithURLString:urlString success:^(NSString *onceString, id responseObject) {
        NSDictionary *parameters = @{kOnceString: onceString,
                                     @"title": title,
                                     @"content": content,
                                     };
        [self requestWithMethod:V2RequestMethodHTTPPOST URLString:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSString *favString = [self getFavUrlStringFromResponseObject:responseObject];
            NSString *regex = @"topic/(.*?)?t";
            NSString *topicIdString = [favString stringByMatching:regex];
            topicIdString = [topicIdString stringByReplacingOccurrencesOfString:@"topic/" withString:@""];
            topicIdString = [topicIdString stringByReplacingOccurrencesOfString:@"?t" withString:@""];
            success(topicIdString);
        } failure:^(NSError *error) {
            failure(error);
        }];
    } failure:^(NSError *error) {
        failure(error);
    }];
    
    return nil;
    
}


#pragma mark - Public Request Methods - Login & Profile

- (NSURLSessionDataTask *)userLoginWithUsername:(NSString *)username
                                       password:(NSString *)password
                                        success:(void (^)(NSString *message))success
                                        failure:(void (^)(NSError *error))failure {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    [self requestOnceWithURLString:@"/signin" success:^(NSString *onceString, id respnseObject) {
        NSDictionary *loginDict =  [self getLoginDictFromHtmlResponseObject:respnseObject];
        
        NSDictionary *parameters = @{
                                     kOnceString: onceString,
                                     kNextString: @"/",
                                     loginDict[kLoginPassword] ?: @"p": password,
                                     loginDict[kLoginUsername] ?: @"u": username,
                                     };
        [self.manager.requestSerializer setValue:@"https://v2ex.com/signin" forHTTPHeaderField:@"Referer"];
        [self requestWithMethod:V2RequestMethodHTTPPOST URLString:@"/signin" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            if ([htmlString rangeOfString:@"/notifications"].location != NSNotFound) {
                [[V2CheckInManager manager] resetStatus];
                success(username);
            } else {
                NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeLoginFailure userInfo:nil];
                failure(error);
            }
        } failure:^(NSError *error) {
            failure(error);
        }];
    } failure:^(NSError *error) {
        failure(error);
    }];
    return nil;
}

- (void)UserLogout {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        [storage deleteCookie:cookie];
    }
    self.user = nil;
    [[V2CheckInManager manager] removeStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutSuccessNotification object:nil];
    
}

- (NSURLSessionDataTask *)getFeedURLSuccess:(void (^)(NSURL *feedURL))success
                                    failure:(void (^)(NSError *error))failure {
    return [self requestWithMethod:V2RequestMethodHTTPGETPC URLString:@"/notifications" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSURL *feedURL;
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSString *regex = @"http://(.*?).xml";
        NSString *feedURLString = [htmlString stringByMatching:regex];
        feedURL = [NSURL URLWithString:feedURLString];
        if (feedURL) {
            self.user.feedURL = feedURL;
            success(feedURL);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetFeedURLFailure userInfo:nil];
            failure(error);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

#pragma mark - Notifications
- (NSURLSessionDataTask *)getUserNotificationWithPage:(NSInteger)page
                                              success:(void (^)(NSArray<V2Notification *> *list))success
                                              failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (page) {
        [parameters setObject:@(page) forKey:@"p"];
    }
    return [self requestWithMethod:V2RequestMethodHTTPGET URLString:@"/notifications" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray<V2Notification *> *list = [V2Notification getNotificationFromResponseObject:responseObject] ;
        if (list) {
            success(list);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetNotificationFailure userInfo:nil];
            failure(error);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (NSURLSessionDataTask *)getUserReplyWithUsername:(NSString *)username
                                              page:(NSInteger)page
                                           success:(void (^)(NSArray<V2MemberReply *> *list))success
                                           failure:(void (^)(NSError *error))failure {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (page) {
        [parameters setObject:@(page) forKey:@"p"];
    }
    NSString *urlString = [NSString stringWithFormat:@"/member/%@/replies", username];
    return [self requestWithMethod:V2RequestMethodHTTPGET URLString:urlString parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray<V2MemberReply *> *list = [V2MemberReply getMemberReplyListFromResponseObject:responseObject] ;
        if (list) {
            success(list);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetMemberReplyFailure userInfo:nil];
            failure(error);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}

#pragma mark - CheckIn
- (NSURLSessionDataTask *)getCheckInURLSuccess:(void (^)(NSURL *URL))success
                                       failure:(void (^)(NSError *error))failure {
    return [self requestWithMethod:V2RequestMethodHTTPGET URLString:@"/mission/daily" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *checkInString = [self getCheckInUrlStringFromHtmlResponseObject:responseObject];
        if (checkInString) {
            NSURL *checkInURL = [NSURL URLWithString:checkInString];
            success(checkInURL);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetCheckInURLFailure userInfo:nil];
            failure(error);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
}

- (NSURLSessionDataTask *)checkInWithURL:(NSURL *)url
                                 Success:(void (^)(NSInteger count))success
                                 failure:(void (^)(NSError *error))failure {
    
    return [self requestWithMethod:V2RequestMethodHTTPGET URLString:url.absoluteString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *checkInCountString = [self getCheckInCountStringFromHtmlResponseObject:responseObject];
        if (checkInCountString) {
            success([checkInCountString integerValue]);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetCheckInURLFailure userInfo:nil];
            failure(error);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSURLSessionDataTask *)getCheckInCountSuccess:(void (^)(NSInteger count))success
                                         failure:(void (^)(NSError *error))failure {
    return [self requestWithMethod:V2RequestMethodHTTPGET URLString:@"/mission/daily" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *checkInCountString = [self getCheckInCountStringFromHtmlResponseObject:responseObject];
        if (checkInCountString) {
            success([checkInCountString integerValue]);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetCheckInURLFailure userInfo:nil];
            failure(error);
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

#pragma mark - Private Methods

- (NSURLSessionDataTask *)requestOnceWithURLString:(NSString *)urlString success:(void (^)(NSString *onceString, id responseObject))success
                                           failure:(void (^)(NSError *error))failure {
    return [self requestWithMethod:V2RequestMethodHTTPGET URLString:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *onceString = [self getOnceStringFromHtmlResponseObject:responseObject];
        if (onceString) {
            success(onceString, responseObject);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeNoOnceAndNext userInfo:nil];
            failure(error);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSString *)getOnceStringFromHtmlResponseObject:(id)responseObject {
    __block NSString *onceString;
    @autoreleasepool {
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
        }
        HTMLNode *bodyNode = [parser body];
        NSArray *inputNodes = [bodyNode findChildrenTag:@"input"];
        [inputNodes enumerateObjectsUsingBlock:^(HTMLNode *aNode, NSUInteger idx, BOOL *stop) {
            if ([[aNode getAttributeNamed:@"name"] isEqualToString:@"once"]) {
                onceString = [aNode getAttributeNamed:@"value"];
            }
        }];
    }
    return onceString;
}

/**
 *  @{
 *     p: passwordKey
 *     n: usernameKey
 *   }
 */
- (NSDictionary *)getLoginDictFromHtmlResponseObject:(id)responseObject {
    __block NSMutableDictionary *loginDict = [NSMutableDictionary new];
    @autoreleasepool {
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
        }
        HTMLNode *bodyNode = [parser body];
        NSArray *inputNodes = [bodyNode findChildrenTag:@"input"];
        [inputNodes enumerateObjectsUsingBlock:^(HTMLNode *aNode, NSUInteger idx, BOOL *stop) {
            if ([[aNode getAttributeNamed:@"type"] isEqualToString:@"text"]) {
                NSString *textName = [aNode getAttributeNamed:@"name"];
                if (textName) {
                    loginDict[kLoginUsername] = textName;
                }
            }
            if ([[aNode getAttributeNamed:@"type"] isEqualToString:@"password"]) {
                NSString *passwordName = [aNode getAttributeNamed:@"name"];
                if (passwordName) {
                    loginDict[kLoginPassword] = passwordName;
                }
            }
        }];
        
    }
    return loginDict;
}

- (NSURLSessionDataTask *)requestIgnoreOnceWithURLString:(NSString *)urlString success:(void (^)(NSString *onceString))success
                                                 failure:(void (^)(NSError *error))failure {
    
    return [self requestWithMethod:V2RequestMethodHTTPGET URLString:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *onceString = [self getIgnoreOnceStringFromHtmlResponseObject:responseObject];
        if (onceString) {
            success(onceString);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeNoOnceAndNext userInfo:nil];
            failure(error);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSString *)getIgnoreOnceStringFromHtmlResponseObject:(id)responseObject {
    
    __block NSString *onceString;
    
    @autoreleasepool {
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSString *regex1 = @"ignore/topic/(.*?)';";
        NSString *regex2 = @"once=(.*?)';";
        NSString *ignoreString = [htmlString stringByMatching:regex1];
        onceString = [ignoreString stringByMatching:regex2];
        onceString = [onceString stringByReplacingOccurrencesOfString:@"once=" withString:@""];
        onceString = [onceString stringByReplacingOccurrencesOfString:@"';" withString:@""];
        
    }
    
    return onceString;
}

- (NSURLSessionDataTask *)requestMemberTokenWithURLString:(NSString *)urlString success:(void (^)(NSString *onceString))success
                                                  failure:(void (^)(NSError *error))failure {
    
    return [self requestWithMethod:V2RequestMethodHTTPGET URLString:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *onceString = [self getMemberTokenFromHtmlResponseObject:responseObject];
        if (onceString) {
            success(onceString);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeNoOnceAndNext userInfo:nil];
            failure(error);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSString *)getMemberTokenFromHtmlResponseObject:(id)responseObject {
    __block NSString *onceString;
    @autoreleasepool {
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSString *regex1 = @"follow/(.*?)';";
        NSString *tokenString = [htmlString stringByMatching:regex1];
        onceString = [tokenString stringByReplacingOccurrencesOfString:@"follow/" withString:@""];
        onceString = [onceString stringByReplacingOccurrencesOfString:@"';" withString:@""];
        
    }
    
    return onceString;
}

- (NSString *)getCheckInUrlStringFromHtmlResponseObject:(id)responseObject {
    __block NSString *checkInUrlString;
    @autoreleasepool {
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        __block NSString *onceToken;
        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
        }
        HTMLNode *bodyNode = [parser body];
        NSArray *inputNodes = [bodyNode findChildrenTag:@"input"];
        [inputNodes enumerateObjectsUsingBlock:^(HTMLNode *aNode, NSUInteger idx, BOOL *stop) {
            NSString *hrefString = [aNode getAttributeNamed:@"onclick"];
            if (hrefString) {
                onceToken = [hrefString stringByReplacingOccurrencesOfString:@"location.href = '" withString:@""];
                onceToken = [onceToken stringByReplacingOccurrencesOfString:@"';" withString:@""];
                *stop = YES;
            }
        }];

        if (onceToken) {
            checkInUrlString = onceToken;
        }
        
    }
    return checkInUrlString;
}

- (NSString *)getCheckInCountStringFromHtmlResponseObject:(id)responseObject {
    
    __block NSString *checkInCountString;
    
    @autoreleasepool {
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSString *regex = @"已连续登录(.*?)天";
        NSString *countString = [htmlString stringByMatching:regex];
        countString = [countString stringByReplacingOccurrencesOfString:@"已连续登录" withString:@""];
        countString = [countString stringByReplacingOccurrencesOfString:@"天" withString:@""];
        countString = [countString stringByReplacingOccurrencesOfString:@" " withString:@""];
        if (countString.length > 0) {
            checkInCountString = countString;
        }
        
    }
    
    return checkInCountString;
}

- (NSURLSessionDataTask *)requestFavUrlWithURLString:(NSString *)urlString success:(void (^)(NSString *urlString))success
                                             failure:(void (^)(NSError *error))failure {
    
    return [self requestWithMethod:V2RequestMethodHTTPGETPC URLString:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *string = [self getFavUrlStringFromResponseObject:responseObject];
        if (string.length < 5) {
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetFavUrlFailure userInfo:nil];
            failure(error);
        } else {
            success(string);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSURLSessionDataTask *)getTopicTokenWithTopicId:(NSString *)topicId
                                           success:(void (^)(NSString *token))success
                                           failure:(void (^)(NSError *error))failure {
    
    NSString *urlString = [NSString stringWithFormat:@"/t/%@", topicId];
    
    return [self requestWithMethod:V2RequestMethodHTTPGET URLString:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *string = [self getTopicTokenFromResponseObject:responseObject];
        if (string.length < 5) {
            NSError *error = [[NSError alloc] initWithDomain:self.manager.baseURL.absoluteString code:V2ErrorTypeGetFavUrlFailure userInfo:nil];
            failure(error);
        } else {
            success(string);
        }
        
    } failure:^(NSError *error) {
        failure(error);
    }];
    
}

- (NSString *)getFavUrlStringFromResponseObject:(id)responseObject {
    
    __block NSString *favUrlString;
    
    @autoreleasepool {
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
        }
        
        HTMLNode *bodyNode = [parser body];
        
        NSArray *aNodes = [bodyNode findChildrenTag:@"a"];
        
        [aNodes enumerateObjectsUsingBlock:^(HTMLNode *aNode, NSUInteger idx, BOOL *stop) {
            if ([aNode.allContents rangeOfString:@"加入收藏"].location != NSNotFound) {
                favUrlString = [aNode getAttributeNamed:@"href"];
                *stop = YES;
            }
            
        }];
        
    }
    
    return favUrlString;
}


- (NSString *)getTopicTokenFromResponseObject:(id)responseObject {
    __block NSString *token;
    @autoreleasepool {
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
        }
        
        HTMLNode *bodyNode = [parser body];
        
        HTMLNode *frNode = [bodyNode findChildOfClass:@"inner"];
        
        NSArray *aNodes = [frNode findChildrenTag:@"a"];
        
        [aNodes enumerateObjectsUsingBlock:^(HTMLNode *aNode, NSUInteger idx, BOOL *stop) {
            if ([aNode.allContents rangeOfString:@"收藏"].location != NSNotFound) {
                NSString *hrefString = [aNode getAttributeNamed:@"href"];
                NSArray *components = [hrefString componentsSeparatedByString:@"?t="];
                token = components.lastObject;
                *stop = YES;
            }
            
        }];
        
    }
    
    return token;
}

// 解析关注的节点信息
- (NSArray *)getNodeListFromResponseObject:(id)responseObject {
    NSArray *list;
    
    @autoreleasepool {
        NSString *htmlString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSError *error = nil;
        HTMLParser *parser = [[HTMLParser alloc] initWithString:htmlString error:&error];
        
        if (error) {
            NSLog(@"Error: %@", error);
        }
        
        HTMLNode *bodyNode = [parser body];
        HTMLNode *myNode = [bodyNode findChildWithAttribute:@"id" matchingName:@"MyNodes" allowPartial:YES];
        NSArray *nodes = [myNode findChildrenOfClass:@"grid_item"];
        NSMutableArray *nodesArray = [[NSMutableArray alloc] init];
        [nodes enumerateObjectsUsingBlock:^(HTMLNode *node, NSUInteger idx, BOOL *stop) {
            HTMLNode *numberNode = [node findChildTag:@"span"];
            NSString *nodeName = [node.allContents stringByReplacingOccurrencesOfString:numberNode.allContents withString:@""];
            nodeName = [nodeName stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSString *regex1 = @"href=\"/go/(.*?)\"";
            NSString *nodeIdString = [node.rawContents stringByMatching:regex1];
            nodeIdString = [nodeIdString stringByReplacingOccurrencesOfString:@"href=\"/go/" withString:@""];
            nodeIdString = [nodeIdString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            NSDictionary *nodeDict = @{
                                       @"name": nodeName,
                                       @"title": nodeIdString
                                       };
            [nodesArray addObject:nodeDict];
        }];
        
        list = nodesArray;
    }
    
    return list;
}


@end
