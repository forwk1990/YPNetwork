//
//  YPMethodInvoker.m
//  lujue
//
//  Created by itachi on 16/9/22.
//  Copyright © 2016年 com.bj-evetime. All rights reserved.
//

#import "YPMethodInvoker.h"

@interface YPMethodInvoker ()

@property (nonatomic,strong) NSMutableArray *invocationList;

@end

@implementation YPMethodInvoker

- (instancetype)initWithSelector:(SEL)selector{
    if(self = [super init]){
        _selector = selector;
    }
    return self;
}

+ (instancetype)invokerWithSelector:(SEL)selector{
    return [[self alloc] initWithSelector:selector];
}

- (NSMutableArray *)invocationList{
    if(_invocationList == nil){
        _invocationList = [NSMutableArray array];
    }
    return _invocationList;
}

- (void)registerTarget:(id)target{
    if(![target respondsToSelector:self.selector]) return;
    [self.invocationList addObject:target];
}

- (void)invoke{
    [self invokeWithArguments:nil];
}

- (void)invokeWithObject:(id)object{
    [self invokeWithArguments:@[object]];
}

- (void)invokeWithObject:(id)object1 withObject:(id)object2{
    [self invokeWithArguments:@[object1,object2]];
}

- (void)invokeWithArguments:(NSArray *)arguments{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    __weak typeof(self) weakSelf = self;
    [self.invocationList enumerateObjectsUsingBlock:^(id  _Nonnull target, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong YPMethodInvoker *strongifySelf = weakSelf;
        NSMethodSignature *methodSignature = [target methodSignatureForSelector:strongifySelf.selector];
        NSInteger numberOfArguments = [methodSignature numberOfArguments];
        NSAssert(numberOfArguments == arguments.count + 2, @"invalide arguments");
        switch (numberOfArguments) {
            case 2:
                [target performSelector:strongifySelf.selector];
                break;
            case 3:
                [target performSelector:strongifySelf.selector withObject:arguments[0]];
                break;
            case 4:
                [target performSelector:strongifySelf.selector withObject:arguments[0] withObject:arguments[1]];
                break;
            default:
                break;
        }
    }];
#pragma clang diagnostic pop
}


@end
