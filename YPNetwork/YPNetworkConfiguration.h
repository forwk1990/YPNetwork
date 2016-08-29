//
//  YPNetworkConfiguration.h
//  lujue
//
//  Created by itachi on 16/8/23.
//  Copyright © 2016年 com.bj-evetime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPNetworkCommonHeader.h"

@interface YPNetworkConfiguration : NSObject

+ (instancetype)configuration;

@property (nonatomic,copy) NSString *baseUrl;
@property (nonatomic,assign) YPHttpSerializerType requestSerializerType;
@property (nonatomic,assign) YPHttpSerializerType responseSerializerType;
@property (nonatomic,copy) NSDictionary<NSString*, NSString*> *authenticationHeaders;
@property (nonatomic,copy) NSDictionary<NSString*,NSString*> *requestHeaders;
@property (nonatomic,assign) NSTimeInterval timeoutInterval;
@property (nonatomic,strong) NSMutableDictionary<NSString *, NSString *> *paths;
@property (nonatomic,assign,getter=isDebug) Boolean Debug;

- (void)resolvePathsFromFile:(NSString *)fileName;
- (void)resolvePathsFromFile:(NSString *)fileName ofType:(NSString *)fileType;

@end
