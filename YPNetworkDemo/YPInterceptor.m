//
//  YPInterceptor.m
//  YPNetworkDemo
//
//  Created by itachi on 16/9/27.
//  Copyright © 2016年 com.itachi. All rights reserved.
//

#import "YPInterceptor.h"
#import "YPNetworkResponse.h"

@implementation YPInterceptor

- (void)networkManager:(YPNetworkManager *)networkManager willHandleResponse:(YPNetworkResponse *)responseObject{
    responseObject.responseObject = @{@"hello":@"world"};
}

- (void)networkManager:(YPNetworkManager *)networkManager didHandleResponse:(YPNetworkResponse *)responseObject{
    NSLog(@"%@",responseObject);
}

@end
