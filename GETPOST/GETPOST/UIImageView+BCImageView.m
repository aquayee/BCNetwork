//
//  UIImageView+BCImageView.m
//  GETPOST
//
//  Created by A on 15/8/5.
//  Copyright (c) 2015年 林柏参. All rights reserved.
//

#import "UIImageView+BCImageView.h"
#import <UIImageView+WebCache.h>

@implementation UIImageView (BCImageView)

/**
 *  图片缓存
 *
 *  @param cacheImageView 缓存的图片
 *  @param url            图片的url
 */
+(void)cacheImageView:(UIImageView *)cacheImageView url:(NSString *)url
{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    UIImage *cacheImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:url];
    
    if (cacheImage) {
        [cacheImageView setImage:cacheImage];
        //        NSLog(@" 有图片缓存 ");
    }else{
        [manager downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image) {
                //                NSLog(@"没有图片缓存");
                [cacheImageView setImage:image];
                [[SDImageCache sharedImageCache]storeImage:image forKey:url toDisk:YES];
            }
        }];
    }
}

@end
