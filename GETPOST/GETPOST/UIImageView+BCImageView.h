//
//  UIImageView+BCImageView.h
//  GETPOST
//
//  Created by A on 15/8/5.
//  Copyright (c) 2015年 林柏参. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (BCImageView)

/**
 *  图片缓存
 *
 *  @param cacheImageView 缓存的图片
 *  @param url            图片的url
 */
+(void)cacheImageView:(UIImageView *)cacheImageView url:(NSString *)url;

@end
