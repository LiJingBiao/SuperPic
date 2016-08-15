//
//  FKFileManager.h
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/31.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FKFileManager : NSObject
+(NSString *)documentsPath;//获取documents目录
+(NSString *)myGifPath;//获取的图片目录
+(NSString *)webCachePath;//获取缓存目录
+(NSString *)imgPathInWebCacheWithName:(NSString *)imageName;
+(NSArray *)imagePathInMyGif;//获取gif下面所有图片文件
+(NSArray *)imagePathInMyWebCachePath;//获取webCache下面所有图片文件
+(NSArray *)imagePathFromDirectory;//获取itunes下面所有图片文件
+(BOOL)copyItemPathToMyGifPathFromPath:(NSString *)fromPath;//从另一个路径拷贝到我的gif路径
+(void)removeImageAtPath:(NSString *)path;

+(BOOL)myGifPathWriteImageData:(NSData*)imageData withName:(NSString *)imageName;
@end

@interface FKShareManager : NSObject
+(void)shareImageWithData:(NSData *)imageData isWX:(BOOL)isWX;
@end