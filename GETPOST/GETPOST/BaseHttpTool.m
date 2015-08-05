
#import "BaseHttpTool.h"
#import <YTKKeyValueStore/YTKKeyValueStore.h>
#import <AFNetworking/AFNetworking.h>

@implementation BaseHttpTool

static NSString *_tableName;
static YTKKeyValueStore *_store;
+(void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _store = [[YTKKeyValueStore alloc] initDBWithName:@"CBTCache.db"];
        _tableName = @"user_table";
        [_store createTableWithName:_tableName];
    });
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
            
            NSDictionary *queryUser = [_store getObjectById:url fromTable:_tableName];
            if (queryUser) {
                sucess(queryUser);
//                NSLog(@"系统有缓存 %@",queryUser);
            }
            
            [mgr GET:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (sucess) {
                    if (!queryUser) {
                        sucess(responseObject);
//                        NSLog(@"第一次进入系统没有缓存");
                    }
                        [_store putObject:responseObject withId:url intoTable:_tableName];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if (failur) {
                    failur(error);
                }
            }];
        }
            break;
    }
}

/**
 *  PUT
 *
 *  @param url    请求的 url
 *  @param parm   请求的参数
 *  @param sucess 请求成功后的回调
 *  @param failur 请求失败后的回调
 */
+(void)putWithUrl:(NSString *)url parm:(id)parm sucess:(void (^)(id json))sucess failur:(void (^)(NSError *error))failur
{
    [[AFHTTPSessionManager manager] PUT:url parameters:parm success:^(NSURLSessionDataTask *task, id responseObject) {
        if (sucess) {
            sucess(responseObject);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failur) {
            failur(error);
        }
    }];
}

/**
 *  DELETE
 *
 *  @param url    请求的 url
 *  @param parm   请求的参数
 *  @param sucess 请求成功后的回调
 *  @param failur 请求失败后的回调
 */
+(void)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters sucess:(void (^)(id json))sucess failur:(void (^)(NSError *error))failur
{
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    [mgr DELETE:URLString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (sucess) {
            sucess(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failur) {
            failur(error);
        }
    }];
}

@end
