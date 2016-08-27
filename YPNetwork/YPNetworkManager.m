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

+ (instancetype)manager{
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
    if(error != nil){
        return contentOfFile;
    }
    else{
        return @"";
    }
}

- (void)sendRequest{
    
    // before send intercptor
    if([self.interceptor respondsToSelector:@selector(beforeRequest)]){
        [self.interceptor performSelector:@selector(beforeRequest)];
    }
    
    NSString *relativeUrl = [self.delegate requestUrl];
    YPHttpRequestProxy *requestProxy = [YPHttpRequestProxy proxy];
    [self semaphoreLockProtectBlock:^{
        // prev request not complete , cancel it
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
    
    // get the ture url from configuration paths
    YPNetworkConfiguration *configuration = [YPNetworkConfiguration configuration];
    if([[[configuration paths] allKeys] containsObject:relativeUrl]){
        relativeUrl = configuration.paths[relativeUrl];
    }
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[[YPNetworkConfiguration configuration] baseUrl],relativeUrl];
    if(configuration.isDebug){
        NSLog(@"%@ -- %@",[self.delegate requestUrl],requestUrl);
    }
    NSURLSessionTask *sessionTask = [requestProxy requestWithType:YPHttpRequestTypePost url:requestUrl parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self semaphoreLockProtectBlock:^{
            [self.dispatchedSessionTask removeObjectForKey:relativeUrl];
        }];
        if([self.interceptor respondsToSelector:@selector(beforeManipulateSucessResponseObject:)]){
            [self.interceptor performSelector:@selector(beforeManipulateSucessResponseObject:) withObject:responseObject];
        }
        [self.delegate performSelector:@selector(networkManager:successResponseObject:) withObject:self withObject:responseObject];
        if([self.interceptor respondsToSelector:@selector(afterManipulateSuccessResponseObject:)]){
            [self.interceptor performSelector:@selector(afterManipulateSuccessResponseObject:) withObject:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self semaphoreLockProtectBlock:^{
            [self.dispatchedSessionTask removeObjectForKey:relativeUrl];
        }];
        if([self.interceptor respondsToSelector:@selector(beforeManipulateError:)]){
            [self.interceptor performSelector:@selector(beforeManipulateError:) withObject:error];
        }
        [self.delegate performSelector:@selector(networkManager:failureResponseError:) withObject:self withObject:error];
        if([self.interceptor respondsToSelector:@selector(afterManipulateError:)]){
            [self.interceptor performSelector:@selector(afterManipulateError:) withObject:error];
        }
    }];
    
    [self semaphoreLockProtectBlock:^{
        self.dispatchedSessionTask[relativeUrl] = [NSString stringWithFormat:@"%lu",sessionTask.taskIdentifier];
    }];
}


@end
