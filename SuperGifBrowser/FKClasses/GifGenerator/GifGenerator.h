//
//  GifGenerator.h
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/4/12.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VideoToImagesGifBlock)(NSString *VideoToImagesGifPath, NSError *error);

@interface GifGenerator : NSObject
+ (GifGenerator *)shared;
//-(void)generatorGifWithVideoPath:(NSString *)path VideoToImagesGifBlock:(VideoToImagesGifBlock)block;
-(void)buildGifWithVideoPath:(NSString *)path VideoToImagesGifBlock:(VideoToImagesGifBlock)block;
-(void)generatorGifWithVideoURL:(NSURL *)url VideoToImagesGifBlock:(VideoToImagesGifBlock)block;
@end
