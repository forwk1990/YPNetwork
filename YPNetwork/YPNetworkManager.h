//
//  YPNetworkManage.h
//  lujue
//
//  Created by itachi on 16/8/23.
//  Copyright © 2016年 com.bj-evetime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPHttpRequestProxy.h"
#import "YPNetworkConfiguration.h"
#import "YPNetworkInterceptor.h"

@class YPNetworkManager;

@protocol YPNetworkManagerDelegate <NSObject>

@optional
- (YPHttpSerializerType)requestSerializerType;
- (YPHttpSerializerType)responseSerializerType;
- (NSTimeInterval)timeoutInterval;
- (NSDictionary<NSString*, NSString*> *)authenticationHeaders;
- (NSDictionary<NSString*, NSString*> *)requestHeaders;

@required
- (NSString *)requestUrl;
- (NSDictionary<NSString*,id>*)parameters;
- (void)networkManager:(YPNetworkManager *)manager successResponseObject:(id)responseObject;
- (void)networkManager:(YPNetworkManager *)manager failureResponseError:(NSError *)error;

@end

@interface YPNetworkManager : NSObject

+ (instancetype)defaultManager;

@property (nonatomic,strong) id responseObject;
@property (nonatomic,strong) id responseString;
@property (nonatomic,weak) id<YPNetworkManagerDelegate> delegate;
@property (nonatomic,weak) id<YPNetworkInterceptor> interceptor;

- (void)sendRequest;
- (NSString *)performRequestFromLocalFile:(NSString *)localFileName;

/// 获取当前请求的URL地址
- (NSString *)requestUrl;
/// 获取当前请求的URL参数
- (NSDictionary<NSString*,id>*)requestParameters;

@end
