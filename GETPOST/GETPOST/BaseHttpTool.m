
#import "BaseHttpTool.h"
#import "Reachability.h"
//#import "ASIFormDataRequest.h"
#import "AFNetworking.h"
#import "YTKKeyValueStore.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation BaseHttpTool

static YTKKeyValueStore *store;

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

+(void)getWithUrl:(NSString *)url parameters:(NSDictionary *)parameters sucess:(BaseHttpToolSucess)sucess failur:(BaseHttpToolFailur)failur
{
    // 1.创建GET请求
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    // 开启网络指示器
    [[AFNetworkActivityIndicatorManager sharedManager]setEnabled:YES];
    
    // 2.发送请求
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
    
    // 这个底层封装的是ASI get请求
//    [BaseHttpTool requestWithMethod:@"GET" url:url parameters:parameters sucess:sucess failur:failur];
}

+(void)getCacheWithUrl:(NSString *)url parameters:(NSDictionary *)parameters sucess:(BaseHttpToolSucess)sucess failur:(BaseHttpToolFailur)failur
{
    // 1.创建GET请求
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    // 开启网络指示器
    [[AFNetworkActivityIndicatorManager sharedManager]setEnabled:YES];
    
    // 判断网络连接
    int status = [BaseHttpTool reachabilityConnectionNetWork];
    
    // 数据库
    NSString *tableName = @"user_table";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [[YTKKeyValueStore alloc] initDBWithName:@"JsonCache.db"];
    });
    [store createTableWithName:tableName];

    if (status == 0) { // 没有网络
        NSDictionary *queryUser = [store getObjectById:url fromTable:tableName];
        if (queryUser) {
            sucess(queryUser);
        }
        failur(failur);
    }else if (status == 1) // 有网络
    {
        // 发送请求
        [mgr GET:url parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
             if (sucess) {
                 [store putObject:responseObject withId:url intoTable:tableName];
                 sucess(responseObject);
             }
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             if (failur) {
                 failur(error);
             }
         }];
    }
}

#warning 如果需要使用 ASI 请注释 AFN 打开这里的 ASI

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

+(int)reachabilityConnectionNetWork
{
    Reachability *connectionNetWork = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    int status = [connectionNetWork currentReachabilityStatus];
    return status;
}

@end
