//
//  ViewController.m
//  Demo
//
//  Created by 林柏参 on 14/10/21.
//  Copyright (c) 2014年 林柏参. All rights reserved.
//

#import "ViewController.h"
#import "BaseHttpTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /**
     *  自行修改接口地址 否则请求失败
     *  带缓存的get请求   需要导入 sql 框架
     */

    NSString *url = @"www.xxx.com";
    [BaseHttpTool getCacheWithUrl:url parameters:nil sucess:^(NSDictionary *json) {
        
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"请求成功,往下看控制器打印的结果吧" message:nil delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [al show];
        
        NSLog(@"sucess json - %@",json);
        
    } failur:^(NSError *error) {
        
        UIAlertView *al = [[UIAlertView alloc]initWithTitle:@"请在 ViewController,修改接口地址,请求失败" message:[error description] delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [al show];
        
        NSLog(@"error  - %@",[error description]);
    }];
}

@end
