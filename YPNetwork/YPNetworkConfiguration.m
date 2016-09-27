//
//  YPNetworkConfiguration.m
//  lujue
//
//  Created by itachi on 16/8/23.
//  Copyright © 2016年 com.bj-evetime. All rights reserved.
//

#import "YPNetworkConfiguration.h"

@implementation YPNetworkConfiguration{
    NSMutableArray<id<YPNetworkInterceptor>> *_interceptors;
}

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
        
#ifdef DEBUG
        self.Debug = YES;
#else
        self.Debug = NO;
#endif
        
        if(_interceptors == nil){
            _interceptors = [NSMutableArray array];
        }
    }
    return self;
}

- (NSArray<id<YPNetworkInterceptor>> *)interceptors{
    return _interceptors;
}

- (NSMutableDictionary<NSString *,NSString *> *)paths{
    if(_paths == nil){
        _paths = [NSMutableDictionary dictionary];
    }
    return _paths;
}

- (void)registerInterceptorWithClass:(Class)cls{
    if(![cls conformsToProtocol:@protocol(YPNetworkInterceptor)]) return;
    [_interceptors addObject:[[cls alloc] init]];
}

- (void)resolvePathsFromFile:(NSString *)fileName{
    if([fileName hasSuffix:@"plist"]){
        [self _resolvePathsFromPlistFile:fileName];
    }
}

- (void)resolvePathsFromFile:(NSString *)fileName ofType:(NSString *)fileType{
    if([fileType isEqualToString:@""] || fileType == nil){
        [self resolvePathsFromFile:fileName];
        return;
    }
    if([fileType isEqualToString:@"plist"]){
        [self _resolvePathsFromPlistFile:[fileName stringByAppendingPathExtension:fileType]];
    }
}

- (void)_resolvePathsFromPlistFile:(NSString *)fileName{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSDictionary *paths = [NSDictionary dictionaryWithContentsOfFile:filePath];
    __weak typeof(self) weakSelf = self;
    [paths enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if([key isKindOfClass:NSClassFromString(@"NSString")]
           && [obj isKindOfClass:NSClassFromString(@"NSString")]){
            __strong YPNetworkConfiguration *strongSelf = weakSelf;
            [strongSelf.paths setValue:obj forKey:key];
        }
    }];
}


@end
