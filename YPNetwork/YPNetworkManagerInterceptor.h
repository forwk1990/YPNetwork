//
//  YPNetworkInterceptor.h
//  YPNetworkDemo
//
//  Created by 尹攀 on 16/9/6.
//  Copyright © 2016年 com.itachi. All rights reserved.
//

#ifndef YPNetworkInterceptor_h
#define YPNetworkInterceptor_h

@protocol YPNetworkManagerInterceptor <NSObject>

@optional
- (void)beginRequest;
- (void)preSuccessHandlerExecuteResponse:(id)responseObject;
- (void)postSuccessHandlerExecuteResponse:(id)responseObject;
- (void)preFailureHandlerExecuteError:(NSError *)error;
- (void)postFailureHandlerExecuteError:(NSError *)error;
- (void)endRequestWithResponse:(id)response orError:(NSError *)error;
@end

#endif /* YPNetworkInterceptor_h */
