//
//  YPMethodInvoker.h
//  lujue
//
//  Created by itachi on 16/9/22.
//  Copyright © 2016年 com.bj-evetime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YPMethodInvoker : NSObject

@property (nonatomic,assign,readonly) SEL selector;

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSelector:(SEL)selector;
+ (instancetype)invokerWithSelector:(SEL)selector;

- (void)registerTarget:(id)target;

- (void)invoke;
- (void)invokeWithObject:(id)object;
- (void)invokeWithObject:(id)object1 withObject:(id)object2;
- (void)invokeWithArguments:(NSArray *)arguments;

@end
