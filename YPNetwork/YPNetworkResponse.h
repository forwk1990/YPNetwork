//
//  YPNetworkResponse.h
//  YPNetworkDemo
//
//  Created by itachi on 16/9/27.
//  Copyright © 2016年 com.itachi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YPNetworkResponse : NSObject

@property (nonatomic,assign,getter=isSuccess) BOOL success;
@property (nonatomic,copy) NSString *errorMessage;
@property (nonatomic,strong) NSObject *responseObject;

- (instancetype)initWithResponseObject:(NSObject *)responseObject;

@end
