//
//  YPNetworkManage.m
//  lujue
//
//  Created by itachi on 16/8/23.
//  Copyright © 2016年 com.bj-evetime. All rights reserved.
//

#import "YPNetworkManager.h"

#define setRequestProxyValueByKey(key) \
if([self.delegate respondsToSelector:@selector(key)]){\
    requestProxy.key = [self.delegate key];\
}else{\
    requestProxy.key = [[YPNetworkConfiguration configuration] key];\
}\


@interface YPNetworkManager ()

@property (nonatomic,strong) NSMutableDictionary<NSString *, NSString *> *dispatchedSessionTask;

@end

@implementation YPNetworkManager{
    dispatch_semaphore_t _semaphoreLock;
}

static YPNetworkManager* _instance = nil;

+ (instancetype)defaultManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[YPNetworkManager alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (instancetype)init{
    if(self = [super init]){
        _semaphoreLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (NSMutableDictionary<NSString *,NSString *> *)dispatchedSessionTask{
    if(_dispatchedSessionTask == nil){
        _dispatchedSessionTask = [NSMutableDictionary dictionary];
    }
    return _dispatchedSessionTask;
}

- (void)semaphoreLockProtectBlock:(void (^)())block{
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    if(block != nil){
        block();
        block = nil;
    }
    dispatch_semaphore_signal(_semaphoreLock);
}

- (NSString *)performRequestFromLocalFile:(NSString *)localFileName{
    NSString *fileFullName = [[NSBundle mainBundle] pathForResource:localFileName ofType:nil];
    NSError *error;
    NSString *contentOfFile = [NSString stringWithContentsOfFile:fileFullName encoding:NSUTF8StringEncoding error:&error];
    if(error == nil){
        return contentOfFile;
    }
    else{
        return @"";
    }
}

- (void)sendRequest{
    @weakify(self)
    
    // 发送之前调用请求前aop
    if([self.interceptor respondsToSelector:@selector(beginRequest)]){
        [self.interceptor performSelector:@selector(beginRequest)];
    }
    
    NSString *relativeToken = [self.delegate requestUrl];
    NSString *relativeUrl = @"";
    
    // 根据urlToken获取真实相对路径
    YPNetworkConfiguration *configuration = [YPNetworkConfiguration configuration];
    if([[[configuration paths] allKeys] containsObject:relativeToken]){
        relativeUrl = configuration.paths[relativeToken];
    }else{
        relativeUrl = relativeToken;
    }
    
    // 获取绝对路径,该路径可直接用于请求
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[[YPNetworkConfiguration configuration] baseUrl],relativeUrl];
    if(configuration.isDebug){
        NSLog(@"Network manager Debug : %@ -- %@",relativeToken,requestUrl);
        NSString *localJsonFileContent = [self performRequestFromLocalFile:[relativeToken stringByAppendingPathExtension:@"json"]];
        if(![localJsonFileContent isEmpty] && ![localJsonFileContent isEmptyString]){
            NSLog(@"Network manager Debug : Find local json file");
            NSData *jsonData = [localJsonFileContent dataUsingEncoding:NSUTF8StringEncoding];
            NSError *serializationError;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&serializationError];
            if(serializationError == nil){
                [self.delegate performSelector:@selector(networkManager:successResponseObject:) withObject:self withObject:jsonObject];
            }else{
                [self.delegate performSelector:@selector(networkManager:failureResponseError:) withObject:serializationError];
            }
            return;
        }
    }
    
    YPHttpRequestProxy *requestProxy = [YPHttpRequestProxy proxy];
    [self semaphoreLockProtectBlock:^{
        // 如果之前的请求还未结束，取消它
        if([self.dispatchedSessionTask.allKeys containsObject:relativeUrl]){
            [requestProxy cancelbyIdentifier:self.dispatchedSessionTask[relativeUrl]];
            [self.dispatchedSessionTask removeObjectForKey:relativeUrl];
        }
    }];
    
    setRequestProxyValueByKey(timeoutInterval)
    setRequestProxyValueByKey(requestSerializerType)
    setRequestProxyValueByKey(responseSerializerType)
    setRequestProxyValueByKey(authenticationHeaders)
    setRequestProxyValueByKey(requestHeaders)
    
    NSDictionary *parameters = [self.delegate parameters];
    NSURLSessionTask *sessionTask = [requestProxy requestWithType:YPHttpRequestTypePost url:requestUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self)
        [self semaphoreLockProtectBlock:^{
            [self.dispatchedSessionTask removeObjectForKey:relativeUrl];
        }];
        if([self.interceptor respondsToSelector:@selector(preSuccessHandlerExecuteResponse:)]){
            [self.interceptor performSelector:@selector(preSuccessHandlerExecuteResponse:) withObject:responseObject];
        }
        [self.delegate performSelector:@selector(networkManager:successResponseObject:) withObject:self withObject:responseObject];
        if([self.interceptor respondsToSelector:@selector(postSuccessHandlerExecuteResponse:)]){
            [self.interceptor performSelector:@selector(postSuccessHandlerExecuteResponse:) withObject:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        @strongify(self)
        [self semaphoreLockProtectBlock:^{
            [self.dispatchedSessionTask removeObjectForKey:relativeUrl];
        }];
        if([self.interceptor respondsToSelector:@selector(preFailureHandlerExecuteError:)]){
            [self.interceptor performSelector:@selector(preFailureHandlerExecuteError:) withObject:error];
        }
        [self.delegate performSelector:@selector(networkManager:failureResponseError:) withObject:self withObject:error];
        if([self.interceptor respondsToSelector:@selector(postFailureHandlerExecuteError:)]){
            [self.interceptor performSelector:@selector(postFailureHandlerExecuteError:) withObject:error];
        }
    }];
    
    [self semaphoreLockProtectBlock:^{
        self.dispatchedSessionTask[relativeUrl] = [NSString stringWithFormat:@"%lu",sessionTask.taskIdentifier];
    }];
    
}


@end
