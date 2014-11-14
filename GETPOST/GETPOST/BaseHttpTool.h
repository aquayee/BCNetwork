/**
 *  封装的网络请求 支持ASI 和 最新的AFN
 *  默认使用 AFN 有其他需求需要使用ASI的，注视相关代码，打开ASI即可
 *  邮箱 : sshare@qq.com
 */

#import <Foundation/Foundation.h>

typedef void (^BaseHttpToolSucess)(id json);
typedef void (^BaseHttpToolFailur)(NSError *error);

@interface BaseHttpTool : NSObject

typedef NS_ENUM(NSUInteger, BcRequestCenterCachePolicy) {
    
    /**
     *  普通网络请求,不会有缓存
     */
    BcRequestCenterCachePolicyNormal,
    
    /**
     *  如果有网络直接读网络，如果没网络直接读本地
     */
    BcRequestCenterCachePolicyCacheAndRefresh,
    
    /**
     *  优先读取本地，不管有没有网络，优先读取本地
     */
    BcRequestCenterCachePolicyCacheAndLocal
};

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
 *  带缓存的 get 请求
 *
 *  @param url        接口地址 Url
 *  @param option     枚举,选择缓存策略
 *  @param parameters 请求参数
 *  @param sucess     成功后的回调
 *  @param failur     失败后的回调
 */
+(void)getCacheWithUrl:(NSString *)url option:(BcRequestCenterCachePolicy)option parameters:(NSDictionary *)parameters sucess:(BaseHttpToolSucess)sucess failur:(BaseHttpToolFailur)failur;

@end
