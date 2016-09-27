//
//  YPNetworkManage.m
//  lujue
//
//  Created by itachi on 16/8/23.
//  Copyright © 2016年 com.bj-evetime. All rights reserved.
//

#import "YPNetworkManager.h"
#import "YPMethodInvoker.h"
#import "YPNetworkResponse.h"

#define setRequestProxyValueByKey(key) \
if([self.delegate respondsToSelector:@selector(key)]){\
    requestProxy.key = [self.delegate key];\
}else{\
    requestProxy.key = [[YPNetworkConfiguration configuration] key];\
}\

#define kNetworkBeginRequest NSStringFromSelector(@selector(networkManagerBeginRequest:))
#define kNetworkPreSuccess NSStringFromSelector(@selector(networkManager:willHandleResponse:))
#define kNetworkPostSuccess NSStringFromSelector(@selector(networkManager:didHandleResponse:))
#define kNetworkPreFailure NSStringFromSelector(@selector(networkManager:willHandleError:))
#define kNetworkPostFailure NSStringFromSelector(@selector(networkManager:didHandleError:))
#define kNetworkEndRequest NSStringFromSelector(@selector(networkManagerEndRequest:))


@interface YPNetworkManager ()

@property (nonatomic,strong) NSMutableDictionary<NSString *, NSString *> *dispatchedSessionTask;
@property (nonatomic,strong) NSMutableDictionary<NSString *, YPMethodInvoker *> *interceptorSteps;

@end

@implementation YPNetworkManager{
    dispatch_semaphore_t _semaphoreLock;
    BOOL _interceptorsInitialized;
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
        _interceptorsInitialized = NO;
    }
    return self;
}

- (NSMutableDictionary<NSString *,NSString *> *)dispatchedSessionTask{
    if(_dispatchedSessionTask == nil){
        _dispatchedSessionTask = [NSMutableDictionary dictionary];
    }
    return _dispatchedSessionTask;
}

-  (NSMutableDictionary<NSString *,YPMethodInvoker *> *)interceptorSteps{
    if(_interceptorSteps == nil){
        _interceptorSteps = [NSMutableDictionary dictionary];
    }
    return _interceptorSteps;
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

- (void)buildInterceptorStepWithSelector:(SEL)selector{
    NSString *selectorString = NSStringFromSelector(selector);
    self.interceptorSteps[selectorString] = [YPMethodInvoker invokerWithSelector:selector];
}

- (void)buildInterceptorSteps{
    @weakify(self)
    
    /// initialize interceptor steps
    [self buildInterceptorStepWithSelector:@selector(networkManagerBeginRequest:)];
    [self buildInterceptorStepWithSelector:@selector(networkManager:willHandleResponse:)];
    [self buildInterceptorStepWithSelector:@selector(networkManager:didHandleResponse:)];
    [self buildInterceptorStepWithSelector:@selector(networkManager:willHandleError:)];
    [self buildInterceptorStepWithSelector:@selector(networkManager:didHandleError:)];
    [self buildInterceptorStepWithSelector:@selector(networkManagerEndRequest:)];
    
    /// 搭建调用对象链
    YPNetworkConfiguration *configuration = [YPNetworkConfiguration configuration];
    [configuration.interceptors enumerateObjectsUsingBlock:^(id<YPNetworkInterceptor>  _Nonnull target, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        [self registerInterceptorTagert:target];
    }];
    
    // 链接自身inteceptor
    [self registerInterceptorTagert:self];
}

- (void)registerInterceptorTagert:(id)target{
    if([target respondsToSelector:@selector(networkManagerBeginRequest:)]){
        [self.interceptorSteps[kNetworkBeginRequest] registerTarget:target];
    }
    if([target respondsToSelector:@selector(networkManager:willHandleResponse:)]){
        [self.interceptorSteps[kNetworkPreSuccess] registerTarget:target];
    }
    if([target respondsToSelector:@selector(networkManager:didHandleResponse:)]){
        [self.interceptorSteps[kNetworkPostSuccess] registerTarget:target];
    }
    if([target respondsToSelector:@selector(networkManager:willHandleError:)]){
        [self.interceptorSteps[kNetworkPreFailure] registerTarget:target];
    }
    if([target respondsToSelector:@selector(networkManager:didHandleError:)]){
        [self.interceptorSteps[kNetworkPostFailure] registerTarget:target];
    }
    if([target respondsToSelector:@selector(networkManagerEndRequest:)]){
        [self.interceptorSteps[kNetworkEndRequest] registerTarget:target];
    }
}

- (void)sendRequest{
    @weakify(self)
    
    if(!_interceptorsInitialized){
        [self buildInterceptorSteps];
        _interceptorsInitialized = YES;
    }
    
    // 发送之前调用请求前aop
    [self.interceptorSteps[kNetworkBeginRequest] invokeWithObject:self];
    
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
        //YPLog(@"Network manager Debug : %@ -- %@",relativeToken,requestUrl);
        NSString *localJsonFileContent = [self performRequestFromLocalFile:[relativeToken stringByAppendingPathExtension:@"json"]];
        if(![localJsonFileContent isEmpty] && ![localJsonFileContent isEmptyString]){
            //YPLog(@"Network manager Debug : Find local json file");
            NSData *jsonData = [localJsonFileContent dataUsingEncoding:NSUTF8StringEncoding];
            NSError *serializationError;
            id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&serializationError];
            if(serializationError == nil){
                [self.interceptorSteps[kNetworkPostSuccess] invokeWithObject:self withObject:[[YPNetworkResponse alloc] initWithResponseObject:jsonObject]];
            }else{
                [self.interceptorSteps[kNetworkPostFailure] invokeWithObject:serializationError];
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
        [self.interceptorSteps[kNetworkEndRequest] invokeWithObject:self];
        [self semaphoreLockProtectBlock:^{
            [self.dispatchedSessionTask removeObjectForKey:relativeUrl];
        }];
        YPNetworkResponse *networkResponse = [[YPNetworkResponse alloc] initWithResponseObject:responseObject];
        [self.interceptorSteps[kNetworkPreSuccess] invokeWithObject:self withObject:networkResponse];
        [self.delegate performSelector:@selector(networkManager:successResponseObject:) withObject:self withObject:networkResponse];
        [self.interceptorSteps[kNetworkPostSuccess] invokeWithObject:self withObject:networkResponse];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        @strongify(self)
        [self.interceptorSteps[kNetworkEndRequest] invokeWithObject:self];
        [self semaphoreLockProtectBlock:^{
            [self.dispatchedSessionTask removeObjectForKey:relativeUrl];
        }];
        [self.interceptorSteps[kNetworkPreFailure] invokeWithObject:error];
        [self.delegate performSelector:@selector(networkManager:failureResponseError:) withObject:self withObject:error];
        [self.interceptorSteps[kNetworkPostFailure] invokeWithObject:error];
    }];
    
    [self semaphoreLockProtectBlock:^{
        self.dispatchedSessionTask[relativeUrl] = [NSString stringWithFormat:@"%lu",sessionTask.taskIdentifier];
    }];
    
}

- (NSString *)requestUrl{
    return [self.delegate requestUrl];
}

- (NSDictionary<NSString *,id> *)requestParameters{
    return [self.delegate parameters];
}


@end
