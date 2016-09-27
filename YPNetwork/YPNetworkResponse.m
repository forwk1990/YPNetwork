//
//  YPNetworkResponse.m
//  YPNetworkDemo
//
//  Created by itachi on 16/9/27.
//  Copyright © 2016年 com.itachi. All rights reserved.
//

#import "YPNetworkResponse.h"

@implementation YPNetworkResponse

- (instancetype)init{
    if(self = [super init]){
        self.success = YES;
        self.errorMessage = nil;
    }
    return self;
}

- (instancetype)initWithResponseObject:(NSObject *)responseObject{
    if(self = [self init]){
        self.responseObject = responseObject;
    }
    return self;
}

@end
