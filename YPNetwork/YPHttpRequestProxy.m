//
//  YPHttpRequestProxy.m
//  lujue
//
//  Created by itachi on 16/8/2.
//  Copyright © 2016年 com.bj-evetime. All rights reserved.
//

#import "YPHttpRequestProxy.h"

@interface YPHttpRequestProxy ()

@property (nonatomic,strong) NSMutableDictionary<NSString*,NSURLSessionTask*> *dispatchedTable;

@end

@implementation YPHttpRequestProxy{
    dispatch_semaphore_t _semaphoreLock;
}

static YPHttpRequestProxy* _instance = nil;

+ (instancetype)proxy{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[YPHttpRequestProxy alloc] init];
        // inilialize base information
        _instance.requestSerializerType = YPHttpSerializerTypeDefault;
        _instance.responseSerializerType = YPHttpSerializerTypeDefault;
        _instance.timeoutInterval = 10;
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_instance == nil){
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}

- (instancetype)init{
    if(self = [super init]){
        _semaphoreLock = dispatch_semaphore_create(1);
    }
    return self;
}

- (void)semaphoreLockProtectBlock:(void (^)())block{
    dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
    if(block != nil){
        block();
        block = nil;
    }
    dispatch_semaphore_signal(_semaphoreLock);
}

- (NSMutableDictionary<NSString *,NSURLSessionTask *> *)dispatchedTable{
    if(_dispatchedTable == nil){
        _dispatchedTable = [NSMutableDictionary dictionary];
    }
    return _dispatchedTable;
}

- (nullable NSURLSessionTask *)requestWithType:(YPHttpRequestType)type
                                           url:(NSString *)url
                                    parameters:(NSDictionary *)parameters
                                      progress:(void (^)(NSProgress * _Nonnull))progress
                                       success:(void (^)(NSURLSessionDataTask * _Nonnull, id _Nullable))success
                                       failure:(void (^)(NSURLSessionDataTask * _Nullable, NSError * _Nonnull))failure{
    NSAssert(type == YPHttpRequestTypeGet || type == YPHttpRequestTypePost, @"unknown request type");
    @weakify(self)
    
    NSURLSessionTask *sessionTask = nil;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    if(self.requestSerializerType == YPHttpSerializerTypeJson){
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    if(self.responseSerializerType == YPHttpSerializerTypeJson){
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    
    // set request time out interval
    manager.requestSerializer.timeoutInterval = self.timeoutInterval;
    
    // need server username and password
    if (self.authenticationHeaders != nil
        && [self.authenticationHeaders.allKeys containsObject:@"userName"]
        && [self.authenticationHeaders.allKeys containsObject:@"password"]){
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:self.authenticationHeaders[@"userName"]
                                                                  password:self.authenticationHeaders[@"password"]];
    }
    
    // need add custom value to httpheaders
    [self.requestHeaders enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [manager.requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
    
    SuccessBlock successBlock = ^(NSURLSessionDataTask *task, id _Nullable responseObject){
        @strongify(self)
        success(task,responseObject);
        [self removeDispatchedTaskByIdentifier:sessionTask.taskIdentifier];
    };
    
    FailureBlock failureBlock = ^(NSURLSessionDataTask *task, NSError *error){
        @strongify(self)
        failure(task,error);
        [self removeDispatchedTaskByIdentifier:sessionTask.taskIdentifier];
    };
    
    switch (type) {
        case YPHttpRequestTypeGet:
            sessionTask = [manager GET:url parameters:parameters progress:progress success:successBlock failure:failureBlock];
            break;
        case YPHttpRequestTypePost:
            sessionTask = [manager POST:url parameters:parameters progress:progress success:successBlock failure:failureBlock];
            break;
    }
    
    [self semaphoreLockProtectBlock:^{
        self.dispatchedTable[[NSString stringWithFormat:@"%lu",sessionTask.taskIdentifier]] = sessionTask;
    }];
    
    NSAssert(sessionTask != nil, @"[YPHttpRequestProxy]: request failure");
    return sessionTask;
}

- (void)removeDispatchedTaskByIdentifier:(NSUInteger)identifier{
    [self semaphoreLockProtectBlock:^{
        [self.dispatchedTable removeObjectForKey:[NSString stringWithFormat:@"%lu",identifier]];
    }];
}

- (void)cancelbyIdentifier:(NSString *)identifier{
    [self semaphoreLockProtectBlock:^{
        if(![self.dispatchedTable.allKeys containsObject:identifier]) return;
        [self.dispatchedTable[identifier] cancel];
        [self.dispatchedTable removeObjectForKey:identifier];
    }];
}

- (void)cancelAll{
    [self semaphoreLockProtectBlock:^{
        [self.dispatchedTable enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSURLSessionTask * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj cancel];
        }];
        [self.dispatchedTable removeAllObjects];
    }];
}

@end
