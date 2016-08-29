//
//  NSString+YPNetwork.m
//  YPNetworkDemo
//
//  Created by 尹攀 on 16/8/27.
//  Copyright © 2016年 com.itachi. All rights reserved.
//

#import "NSString+YPNetwork.h"

@implementation NSString (YPNetwork)

- (BOOL)isEmpty{
    if(self == nil){
        return YES;
    }else if(self.length == 0){
        return YES;
    }
    return NO;
}

- (BOOL)isEmptyString{
    if([self stringByReplacingOccurrencesOfString:@" " withString:@""].length == 0){
        return YES;
    }
    return NO;
}

@end
