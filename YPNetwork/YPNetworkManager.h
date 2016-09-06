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

@property (nonatomic,weak) id<YPNetworkManagerDelegate> delegate;
@property (nonatomic,weak) id<YPNetworkManagerInterceptor> interceptor;

- (void)sendRequest;
- (NSString *)performRequestFromLocalFile:(NSString *)localFileName;

@end
