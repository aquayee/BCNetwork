/**
 *  封装的网络请求 支持ASI 和 最新的AFN
 *  默认使用 AFN 有其他需求需要使用ASI的，注视相关代码，打开ASI即可
 *  邮箱 : sshare@qq.com
 */

#import <Foundation/Foundation.h>

typedef void (^BaseHttpToolSucess)(NSDictionary * json);
typedef void (^BaseHttpToolFailur)(NSError *error);

@interface BaseHttpTool : NSObject

/**
 *  普通的 post 请求
 *
 *  @param url        接口地址 Url
 *  @param parameters 请求参数
 *  @param sucess     成功后的回调
 *  @param failur     失败后的回调
 */
+(void)postWithUrl:(NSString *)url parameters:(NSDictionary *)parameters sucess:(BaseHttpToolSucess)sucess failur:(BaseHttpToolFailur)failur;

/**
 *  普通的 get 请求
 *
 *  @param url        接口地址 Url
 *  @param parameters 请求参数
 *  @param sucess     成功后的回调
 *  @param failur     失败后的回调
 */
+(void)getWithUrl:(NSString *)url parameters:(NSDictionary *)parameters sucess:(BaseHttpToolSucess)sucess failur:(BaseHttpToolFailur)failur;

/**
 *  带缓存的 get 请求
 *
 *  @param url        接口地址 Url
 *  @param parameters 请求参数
 *  @param sucess     成功后的回调
 *  @param failur     失败后的回调
 */
+(void)getCacheWithUrl:(NSString *)url parameters:(NSDictionary *)parameters sucess:(BaseHttpToolSucess)sucess failur:(BaseHttpToolFailur)failur;

@end
