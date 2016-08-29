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
#ifdef DEBUG
        self.Debug = YES;
#else
        self.Debug = NO;
#endif
    }
    return self;
}

- (NSMutableDictionary<NSString *,NSString *> *)paths{
    if(_paths == nil){
        _paths = [NSMutableDictionary dictionary];
    }
    return _paths;
}

- (void)resolePathsFromFile:(NSString *)fileName{
    if([fileName hasSuffix:@"plist"]){
        [self _resovlePathsFromPlistFile:fileName];
    }
}

- (void)resolePathsFromFile:(NSString *)fileName ofType:(NSString *)fileType{
    if([fileType isEqualToString:@""] || fileType == nil){
        [self resolePathsFromFile:fileName];
        return;
    }
    if([fileType isEqualToString:@"plist"]){
        [self _resovlePathsFromPlistFile:[fileName stringByAppendingPathExtension:fileType]];
    }
}

- (void)_resovlePathsFromPlistFile:(NSString *)fileName{
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
