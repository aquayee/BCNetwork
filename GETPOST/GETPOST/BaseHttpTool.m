
#import "BaseHttpTool.h"
#import "Reachability.h"
//#import "ASIFormDataRequest.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "YTKKeyValueStore.h"

@implementation BaseHttpTool

static YTKKeyValueStore *_store;

+(void)postWithUrl:(NSString *)url parameters:(NSDictionary *)parameters sucess:(BaseHttpToolSucess)sucess failur:(BaseHttpToolFailur)failur
{
    // 1.创建POST请求
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    
    // 2.发送请求
    [mgr POST:url parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          if (sucess) {
              sucess(responseObject);
          }
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          if (failur) {
              failur(error);
          }
      }];
    
    // 这个底层封装的是ASI post请求
//    [self requestWithMethod:@"POST" url:url parameters:parameters sucess:sucess failur:failur];
}

+(void)getCacheWithUrl:(NSString *)url option:(BcRequestCenterCachePolicy)option parameters:(NSDictionary *)parameters sucess:(BaseHttpToolSucess)sucess failur:(BaseHttpToolFailur)failur
{
    // 1.创建GET请求
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    // 开启网络指示器
    [[AFNetworkActivityIndicatorManager sharedManager]setEnabled:YES];
    [AFHTTPRequestSerializer serializer].timeoutInterval = 1;
    
    // 数据库
    NSString *tableName = @"user_table";
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _store = [[YTKKeyValueStore alloc] initDBWithName:@"JsonCache.db"];
    });
    [_store createTableWithName:tableName];
    
    // 判断网络连接
    int status = [self reachabilityConnectionNetWork];
    
    switch (option) {
        case BcRequestCenterCachePolicyNormal:{ // 普通的网络请求
            
            [mgr GET:url parameters:parameters
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 if (sucess) {
                     sucess(responseObject);
                 }
             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 if (failur) {
                     failur(error);
                 }
             }];
        }
            break;
        case BcRequestCenterCachePolicyCacheAndRefresh:{ //如果有网络直接读网络，如果没网络直接读本地
            
            if (status == 0) { // 没有网络
                NSDictionary *queryUser = [_store getObjectById:url fromTable:tableName];
                if (queryUser) {
                    sucess(queryUser);
                }
                failur(failur);
            }else// 有网络
            {
                // 发送请求
                [mgr GET:url parameters:parameters
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     [_store putObject:responseObject withId:url intoTable:tableName];
                     if (sucess) {
                         sucess(responseObject);
                     }
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if (failur) {
                         failur(error);
                     }
                 }];
            }
        }
            break;
        case BcRequestCenterCachePolicyCacheAndLocal:{ //优先读取本地，不管有没有网络，优先读取本地
            
            if (status == 0) { // 没有网络
                id previouslySaved = [_store getObjectById:url fromTable:tableName];
                if (previouslySaved) {
                    sucess(previouslySaved);
                }
            }else// 有网络
            {
                // 发送请求
                [mgr GET:url parameters:parameters
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {

                     if ([_store getObjectById:url fromTable:tableName]) {
                         sucess([_store getObjectById:url fromTable:tableName]);
                     }else
                     {
                         sucess(responseObject);
                     }
                     
                     [_store putObject:responseObject withId:url intoTable:tableName];
                     
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     if (failur) {
                         failur(error);
                     }
                 }];
            }
        }
            break;
        default:
            break;
    }
    
    // 这个底层封装的是ASI get请求
    //    [BaseHttpTool requestWithMethod:@"GET" url:url parameters:parameters sucess:sucess failur:failur];
}

+(int)reachabilityConnectionNetWork
{
    Reachability *connectionNetWork = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    int status = [connectionNetWork currentReachabilityStatus];
    return status;
}

//+(void)requestWithMethod:(NSString *)method url:(NSString *)url parameters:(NSDictionary *)parameters sucess:(BaseHttpToolSucess)sucess failur:(BaseHttpToolFailur)failur
//{
//    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
//    // 忽略安全证书
//    [request setValidatesSecureCertificate:NO];
//    //设置超时
//    [request setTimeOutSeconds:1];
//    [request setRequestMethod:method];
//
//    //设置表单提交项
//    for(id key in parameters)
//    {
//        [request setPostValue:[parameters objectForKey:key] forKey:key];
//    }
//    [request setDelegate:self];
//
//    //请求执行完会调用block中的代码
////    __unsafe_unretained ASIFormDataRequest *request1 = request;
//    __weak typeof(request) request1 = request;
//
//    [request setCompletionBlock:^{
//
//        NSData *data = [request1 responseData];
//        NSDictionary *datassin = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//        if (sucess) {
//            sucess(datassin);
////            NSLog(@"sucess=====%@",codes);
//        }
//    }];
//
//    //如果出现异常会执行block中的代码
//    [request setFailedBlock:^{
//        if (failur) {
//            failur(failur);
//        }
//    }];
//
//    [request startAsynchronous];
//}

/**
 *  后端需要 每个项目情况不同 根据不同需求 更改
 */
//    NSString *codes;
//    NSUserDefaults *us=[NSUserDefaults standardUserDefaults];
//    if ([us objectForKey:@"httpcode"]) {
//        codes=[us objectForKey:@"httpcode"];
//    }else{
//        codes=[NSString stringWithFormat:@"\\$\\@-%d%d-SEXUALIFEHAIWANG",arc4random_uniform(100000),arc4random_uniform(100000)];
//        [us setValue:codes forKey:@"httpcode"];
//        [us synchronize];
//    }
//    [request setPostValue:codes forKey:@"CODE"];

@end
