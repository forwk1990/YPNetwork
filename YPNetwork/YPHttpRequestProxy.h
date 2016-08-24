//
//  YPHttpRequestProxy.h
//  lujue
//
//  Created by itachi on 16/8/2.
//  Copyright © 2016年 com.bj-evetime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPNetworkCommonHeader.h"
#import "AFNetworking.h"


NS_ASSUME_NONNULL_BEGIN


typedef void (^SuccessBlock)(NSURLSessionDataTask *task, id _Nullable responseObject);
typedef void (^FailureBlock)(NSURLSessionDataTask * _Nullable task, NSError *error);
typedef void (^ProgressBlock)(NSProgress *progress);


@interface YPHttpRequestProxy : NSObject

@property (nonatomic,assign) YPHttpSerializerType requestSerializerType;
@property (nonatomic,assign) YPHttpSerializerType responseSerializerType;
@property (nonatomic,copy) NSDictionary<NSString*, NSString*> *authenticationHeaders;
@property (nonatomic,copy) NSDictionary<NSString*,NSString*> *requestHeaders;
@property (nonatomic,assign) NSTimeInterval timeoutInterval;

+ (instancetype)proxy;

- (nullable NSURLSessionTask *)requestWithType:(YPHttpRequestType)type
                          url:(NSString *)url
                   parameters:(NSDictionary *)parameters
                     progress:(nullable void (^)(NSProgress *progress))progress
                      success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                      failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

- (void)cancelbyIdentifier:(NSString *)identifier;
- (void)cancelAll;

@end

NS_ASSUME_NONNULL_END
