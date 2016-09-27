//
//  YPNetworkInterceptor.h
//  YPNetworkDemo
//
//  Created by 尹攀 on 16/9/6.
//  Copyright © 2016年 com.itachi. All rights reserved.
//

#ifndef YPNetworkInterceptor_h
#define YPNetworkInterceptor_h

@class YPNetworkManager;

@protocol YPNetworkInterceptor <NSObject>

@optional
- (void)networkManagerBeginRequest:(nonnull YPNetworkManager *)networkManager;
- (void)networkManager:(nonnull YPNetworkManager *)networkManager willHandleResponse:(id _Nonnull *)responseObject;
- (void)networkManager:(nonnull YPNetworkManager *)networkManager didHandleResponse:(nullable NSObject *)responseObject;
- (void)networkManager:(nonnull YPNetworkManager *)networkManager willHandleError:(nullable NSError *)error;
- (void)networkManager:(nonnull YPNetworkManager *)networkManager didHandleError:(nullable NSError *)error;
- (void)networkManagerEndRequest:(nonnull YPNetworkManager *)networkManager;
@end

#endif /* YPNetworkInterceptor_h */
