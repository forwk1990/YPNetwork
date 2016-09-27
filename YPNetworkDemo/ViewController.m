//
//  ViewController.m
//  YPNetworkDemo
//
//  Created by itachi on 16/8/24.
//  Copyright © 2016年 com.itachi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <YPNetworkManagerDelegate>

@property (nonatomic,strong) YPNetworkManager *manager;

@end

@implementation ViewController

- (YPNetworkManager *)manager{
    if(_manager == nil){
        _manager = [YPNetworkManager defaultManager];
        _manager.delegate = self;
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor redColor];
    [self.manager sendRequest];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)requestUrl{
    return @"api_getShortMessageCode";
    //return @"/mobile/user/sms_password/send";
}

- (NSDictionary<NSString *,id> *)parameters{
    return @{@"phone": @"13476116543"};
}

- (void)networkManager:(YPNetworkManager *)manager successResponseObject:(id)responseObject{
    
}

- (void)networkManager:(YPNetworkManager *)manager failureResponseError:(NSError *)error{
    NSLog([error description]);
}



@end
