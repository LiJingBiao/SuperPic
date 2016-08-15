//
//  FKAssetManager.h
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/28.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#import <Foundation/Foundation.h>

@interface FKAssetManager : NSObject
+(NSArray *)getPhotoData;
+(NSArray *)arrayPhotoData;
+(NSArray *)arrayPhotoGroup;
+(NSArray *)arrayVideoAsset;
@end
