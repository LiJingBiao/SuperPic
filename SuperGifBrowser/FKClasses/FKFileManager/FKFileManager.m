//
//  FKFileManager.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/31.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//

#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "FKFileManager.h"
#import <ImageIO/ImageIO.h>


static NSString *MYGIF = @"MYGIF";
static NSString *WEBCACHE = @"WEBCACHE";
static NSString *ITUNES = @"ITUNES";
@implementation FKFileManager
+(NSString *)documentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}
+(NSString *)myGifPath;
{
    NSString *documentsDirectory = [self documentsPath];
    if (!documentsDirectory) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *gifDirectory = [documentsDirectory stringByAppendingPathComponent:MYGIF];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:gifDirectory isDirectory:&isDir]) {
        // 创建目录
        [fileManager createDirectoryAtPath:gifDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"不存在");
    }
    return gifDirectory;
}
+(NSString *)webCachePath
{
    NSString *documentsDirectory = [self documentsPath];
    if (!documentsDirectory) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *webCacheDirectory = [documentsDirectory stringByAppendingPathComponent:WEBCACHE];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:webCacheDirectory isDirectory:&isDir]) {
        // 创建目录
        [fileManager createDirectoryAtPath:webCacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"不存在");
    }
    return webCacheDirectory;
}

+(NSArray *)imagePathInMyGif
{
    NSString *myGif = [self myGifPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager subpathsOfDirectoryAtPath: myGif error:nil];
    NSMutableArray *imagePathArray = [[NSMutableArray alloc]initWithCapacity:20];
    if (files.count) {
        for (NSString *path in files) {
            if (![path isEqualToString:@".DS_Store"]) {
                NSString *photoPath = [myGif stringByAppendingPathComponent:path];
                [imagePathArray addObject:photoPath];
            }
        }
        return imagePathArray;
    }
    return nil;
}

+(NSArray *)imagePathInMyWebCachePath
{
    NSString *webCache = [self webCachePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager subpathsOfDirectoryAtPath: webCache error:nil];
    NSMutableArray *imagePathArray = [[NSMutableArray alloc]initWithCapacity:20];
    if (files.count) {
        for (NSString *path in files) {
            if (![path isEqualToString:@".DS_Store"]) {
                NSString *photoPath = [webCache stringByAppendingPathComponent:path];
                [imagePathArray addObject:photoPath];
            }
        }
        return imagePathArray;
    }
    return nil;
}

+(NSString *)iTunesPath
{
    NSString *documentsDirectory = [self documentsPath];
    if (!documentsDirectory) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *webCacheDirectory = [documentsDirectory stringByAppendingPathComponent:ITUNES];
    //[fileManager removeItemAtPath:webCacheDirectory error:nil];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:webCacheDirectory isDirectory:&isDir]) {
        // 创建目录
        [fileManager createDirectoryAtPath:webCacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"不存在");
    }
    
    return webCacheDirectory;
}

+(NSArray *)imagePathFromDirectory
{
    NSString *itunesPath = [self iTunesPath];
    NSLog(@"%@",itunesPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath: [self documentsPath] error:nil];
    NSMutableArray *imagePathArray = [[NSMutableArray alloc]initWithCapacity:20];
    NSError *err;
    
    if (files.count) {
        for (NSString *path in files) {
            //NSLog(@"------:%@",path);
            if (![path isEqualToString:@".DS_Store"]&&![path isEqualToString:MYGIF]&&![path isEqualToString:WEBCACHE]&&![path isEqualToString:ITUNES]) {
                
                NSString *photoPath = [[self documentsPath] stringByAppendingPathComponent:path];
                NSString *toPath = [itunesPath stringByAppendingPathComponent:path];
                [fileManager moveItemAtPath:photoPath toPath:toPath error:&err];
                NSLog(@"err:%@",err);
            }
        }
        
    }
    
    NSArray *itunesFiles = [fileManager contentsOfDirectoryAtPath: [self iTunesPath] error:nil];
    if (itunesFiles.count) {
        for (NSString *path in itunesFiles) {
             NSLog(@"=========:%@",path);
            if (![path isEqualToString:@".DS_Store"]) {
                NSString *photoPath = [[self iTunesPath] stringByAppendingPathComponent:path];
                [imagePathArray addObject:photoPath];
            }
        }
        
    }
    return imagePathArray;
    return nil;
}

+(void)removeImageAtPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL bRet = [fileManager fileExistsAtPath:path];
    if (bRet) {
        //
        NSError *err;
        [fileManager removeItemAtPath:path error:&err];
    }
}

+(NSString *)imgPathInWebCacheWithName:(NSString *)imageName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *webCacheDir = [FKFileManager webCachePath];
    NSString *imagePath = [webCacheDir stringByAppendingPathComponent:imageName];
    BOOL bRet = [fileManager fileExistsAtPath:imagePath];
    if (bRet) {
        //
        return imagePath;
    }
    return nil;
}

+(BOOL)copyItemPathToMyGifPathFromPath:(NSString *)fromPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *gifDir = [FKFileManager myGifPath];
    NSString *toPath = [gifDir stringByAppendingPathComponent:[fromPath lastPathComponent]];
    return [fileManager copyItemAtPath:fromPath toPath:toPath error:nil];
}
+(BOOL)myGifPathWriteImageData:(NSData*)imageData withName:(NSString *)imageName
{
    NSString *gifDir = [FKFileManager myGifPath];
    NSString *toPath = [gifDir stringByAppendingPathComponent:imageName];
    return [imageData writeToFile:toPath atomically:YES];
}
@end


@interface CBImageCompressor : NSObject

+ (void)compressImage:(UIImage *)image limitSize:(NSUInteger)size maxSide:(CGFloat)length
           completion:(void (^)(NSData *data))block;

+ (UIImage *)imageWithMaxSide:(CGFloat)length sourceImage:(UIImage *)image;

@end
@implementation CBImageCompressor

+ (void)compressImage:(UIImage *)image limitSize:(NSUInteger)size maxSide:(CGFloat)length
           completion:(void (^)(NSData *data))block
{
    NSAssert(size > 0, @"图片的大小必须大于 0");
    NSAssert(length > 0, @"图片的最大限制边长必须大于 0");
    
    //NSLog(@"----------图片个数:%d",image.images.count);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 先按比例减少图片的分辨率
        UIImage *img = [CBImageCompressor imageWithMaxSide:length sourceImage:image];
        
        NSData *imgData = UIImageJPEGRepresentation(img, 1.0);
        if (imgData.length <= size) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 返回图片的二进制数据
                block(imgData);
            });
            
            return;
        }
        
        // 如果图片大小仍超过限制大小，则压缩图片的质量
        // 返回以 JPEG 格式表示的图片的二进制数据
        
        CGFloat quality = 0.7;
        do {
            @autoreleasepool {
                imgData = UIImageJPEGRepresentation(img, quality);
                quality -= 0.05;
                NSLog(@"%d", imgData.length);
            }
        } while (imgData.length > size);
        
        // 返回 压缩后的 imgData
        dispatch_async(dispatch_get_main_queue(), ^{
            // 返回图片的二进制数据
            block(imgData);
        });
    });
}

+ (UIImage *)imageWithMaxSide:(CGFloat)length sourceImage:(UIImage *)image
{
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGSize imgSize = CWSizeReduce(image.size, length);
    UIImage *img = nil;
    
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, scale);
    
    [image drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)
            blendMode:kCGBlendModeNormal alpha:1.0];
    
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark - Utility
static inline
CGSize CWSizeReduce(CGSize size, CGFloat limit)   // 按比例减少尺寸
{
    CGFloat max = MAX(size.width, size.height);
    if (max < limit) {
        return size;
    }
    
    CGSize imgSize;
    CGFloat ratio = size.height / size.width;
    
    if (size.width > size.height) {
        imgSize = CGSizeMake(limit, limit*ratio);
    } else {
        imgSize = CGSizeMake(limit/ratio, limit);
    }
    
    return imgSize;
}

@end


@implementation FKShareManager

+(void)shareImageWithData:(NSData *)imageData isWX:(BOOL)isWX
{
    CGImageSourceRef gifSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData,0);
    size_t frameCount = CGImageSourceGetCount(gifSource);
    if (frameCount>1) {
        CGImageRef cgimage= CGImageSourceCreateImageAtIndex(gifSource, 0, NULL);
        UIImage *image = [UIImage imageWithCGImage:cgimage];
        NSData *tmpData = UIImageJPEGRepresentation(image, 0.3);
        if (tmpData.length/1000>=32) {
            [CBImageCompressor compressImage:[UIImage imageWithData:tmpData] limitSize:32*1000 maxSide:100 completion:^(NSData *data) {
                if (isWX) {
                    [self shareImageWithDate:imageData thumbData:data];
                }else{
                    [self shareImageToQQ:imageData thumbData:data];
                }
                
            }];

        }else{
            if (isWX) {
                [self shareImageWithDate:imageData thumbData:tmpData];
            }else{
                [self shareImageToQQ:imageData thumbData:tmpData];
            }
        }
    }else{
        if (imageData.length/1000>=32) {
            [CBImageCompressor compressImage:[UIImage imageWithData:imageData] limitSize:32*1000 maxSide:100 completion:^(NSData *data) {
                if (isWX) {
                    [self shareImageWithDate:imageData thumbData:data];
                }else{
                    [self shareImageToQQ:imageData thumbData:data];
                }
            }];
        }else{
            if (isWX) {
                [self shareImageWithDate:imageData thumbData:imageData];
            }else{
                [self shareImageToQQ:imageData thumbData:imageData];
            }
        }

    }
    //NSLog(@"----------图片个数:%d",frameCount);
    NSLog(@"图片大小：%f",imageData.length/1000.);
    
}
+(void)shareImageWithDate:(NSData *)imageData thumbData:(NSData *)thumbData
{
    //[self shareImageToQQ:imageData thumbData:thumbData];
    //return;
    WXMediaMessage *message = [WXMediaMessage message];
    //[message setThumbImage:[UIImage imageNamed:@"fk"]];
    [message setThumbData:thumbData];
    WXEmoticonObject *ext = [WXEmoticonObject object];
    ext.emoticonData = imageData;
    message.mediaObject = ext;
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    [WXApi sendReq:req];
}

+(void)shareImageToQQ:(NSData *)data thumbData:(NSData *)thumbData{
   TencentOAuth *_tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"222222" andDelegate:nil];
    QQApiImageObject* img = [QQApiImageObject objectWithData:data previewImageData:thumbData title:@"" description:@""];
    SendMessageToQQReq* req = [SendMessageToQQReq reqWithContent:img];
    QQApiSendResultCode sent = [QQApiInterface sendReq:req];
    [self handleSendResult:sent];
    /*会提示（EQQAPIAPPNOTREGISTED ）App未注册的错误//分享给QQ好友文字*/
}


+ (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
}

@end