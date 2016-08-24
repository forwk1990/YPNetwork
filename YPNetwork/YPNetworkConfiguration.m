//
//  YPNetworkConfiguration.m
//  lujue
//
//  Created by itachi on 16/8/23.
//  Copyright © 2016年 com.bj-evetime. All rights reserved.
//

#import "YPNetworkConfiguration.h"

@implementation YPNetworkConfiguration

static YPNetworkConfiguration* _instance = nil;

+ (instancetype)configuration{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[YPNetworkConfiguration alloc] init];
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
        self.timeoutInterval = 5;
    }
    return self;
}

- (void)resolePathsFromFile:(NSString *)fileName{
    
}

@end
