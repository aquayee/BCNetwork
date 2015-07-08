
#import "BaseHttpTool.h"
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"

@implementation BaseHttpTool

//缓存
static NSURLCache* sharedCache = nil;
+(NSURLCache*)sharedCache
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 开启网络指示器
        [[AFNetworkActivityIndicatorManager sharedManager]setEnabled:YES];
        
        NSString *diskPath = [NSString stringWithFormat:@"RequestCenter"];
        sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:1024*1024*10
                                                    diskCapacity:1024*1024*1024
                                                        diskPath:diskPath];
    });
    //    10M内存  1G硬盘
    return sharedCache;
}

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
//    [mgr.requestSerializer setValue:@"application/vnd.xxx.com+json; version=1" forHTTPHeaderField:@"Accept"];
    [AFHTTPRequestSerializer serializer].timeoutInterval = 1;
    
    switch (option) {
        case BcRequestCenterCachePolicyNormal:{ // 普通的网络请求
            
            [mgr GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
        case BcRequestCenterCachePolicyCacheAndLocal:{ //优先读取本地，不管有没有网络，优先读取本地
            
            NSError *serializationError = nil;
            NSMutableURLRequest *request = [mgr.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:url relativeToURL:nil] absoluteString] parameters:parameters error:&serializationError];
            
            __block NSCachedURLResponse *cachedResponse = [[self sharedCache] cachedResponseForRequest:request];
            if (cachedResponse) {
                id json = [NSJSONSerialization JSONObjectWithData:cachedResponse.data options:NSJSONReadingMutableLeaves error:nil];
                sucess(json);
                NSLog(@"缓存后的数据  %@",json);
            }
            
            [mgr GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (sucess) {
                    
                    if (![operation.response.URL isEqual:cachedResponse.response.URL]) {
                        if (sucess) {
                            sucess(responseObject);
                            NSLog(@"第一次进入系统没有缓存%@",responseObject);
                        }
                    }
                    
                    NSData *data = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
                    cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:operation.response data:data userInfo:nil storagePolicy:NSURLCacheStorageAllowed];
                    [[self sharedCache] storeCachedResponse:cachedResponse forRequest:request];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (failur) {
                    failur(error);
                }
            }];
            
        }
            break;
    }
    
    // 这个底层封装的是ASI get请求
    //    [BaseHttpTool requestWithMethod:@"GET" url:url parameters:parameters sucess:sucess failur:failur];
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

@end
