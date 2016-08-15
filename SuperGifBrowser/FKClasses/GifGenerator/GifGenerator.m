//
//  GifGenerator.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/4/12.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import "FKFileManager.h"
#import <stddef.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "GifGenerator.h"


#define BACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)

@interface GifGenerator()
@property (nonatomic, strong) AVAssetImageGenerator *generator;
@end

@implementation GifGenerator

+ (GifGenerator *)shared {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
        
    });
    return instance;
}
-(void)buildGifWithVideoPath:(NSString *)path VideoToImagesGifBlock:(VideoToImagesGifBlock)block{
    __weak typeof(self) weakSelf = self;
    NSLog(@"%@",path);
    NSURL *url = [NSURL fileURLWithPath:path];
    BACK(^{
        [weakSelf generatorGifWithVideoPath:url VideoToImagesGifBlock:block];
    });
}
-(void)generatorGifWithVideoURL:(NSURL *)url VideoToImagesGifBlock:(VideoToImagesGifBlock)block
{
    __weak typeof(self) weakSelf = self;
    BACK(^{
        [weakSelf generatorGifWithVideoPath:url VideoToImagesGifBlock:block];
    });
}
-(void)generatorGifWithVideoPath:(NSURL *)url VideoToImagesGifBlock:(VideoToImagesGifBlock)block
{
    //NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:url options:nil];
    self.generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    self.generator.appliesPreferredTrackTransform = YES;
    //这里调帧图大小，越接近原尺寸就越清晰
    size_t height = (size_t)180;
    size_t width = (size_t)180;
    
    self.generator.maximumSize = CGSizeMake(width, height);
    
    NSError *error = nil;
    NSArray *times = [self generateOffsets:asset];
    
    NSDictionary *images = [self extractFromAssetAt:times error:&error duration:asset.duration];

    
    NSMutableArray *  strip =[NSMutableArray array];
    if (images) {
        
        for (int idx = 0; idx < [times count]; idx++) {
            NSLog(@"-----idx:%d",idx);
            NSNumber *time = [times objectAtIndex:idx];
            CGImageRef image = (__bridge CGImageRef)([images objectForKey:time]);
            UIImage * naImage =[[UIImage alloc]initWithCGImage:image];
            //            naImage= [self scaleToSize:naImage size:CGSizeMake(200, 200)];
            NSData *imagedata =UIImageJPEGRepresentation(naImage, 0.6);
            UIImage * UIImageCompress=[UIImage imageWithData:imagedata];
            UIImage *addimage =[self imageWithLogoText:UIImageCompress text:@"😂"];
            [strip addObject:addimage];
            
            //NSLog(@"%d",idx);
        }
    }
    
    //NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:
      //                    [NSString stringWithFormat:@"temp.gif"]];
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM_dd_hh_mm"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSLog(@"dateString:%@",dateString);
    NSString *myGif = [FKFileManager myGifPath];
    NSString *imagePath =[myGif stringByAppendingPathComponent:dateString];
    imagePath = [imagePath stringByAppendingString:@".gif"];
    NSLog(@"--------:%@",imagePath);
    [self _writeImageAsGIF:strip toPath:imagePath size:(CGSize){480, 320} fps:10 animateTransitions:NO withCallbackBlock:block];
}

- (void)saveGIFToPhotosWithImages:(NSArray *)images
                         withSize:(CGSize)size
                          withFPS:(int)fps
               animateTransitions:(BOOL)animate
                withCallbackBlock:(VideoToImagesGifBlock)callbackBlock {
    
#warning 想要开启保存吧下面这段打开
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
        NSData *data = [NSData dataWithContentsOfFile:@""];
        
        [library writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"Error Saving GIF to Photo Album: %@", error);
                if (callbackBlock) {
                    callbackBlock(FALSE ,nil);
                }
                
            } else {
                // TODO: success handling
               // NSLog(@"GIF Saved to %@", tempPath);
                
                
                
                
                
                
                if (callbackBlock) {
                    //callbackBlock(TRUE ,tempPath);
                }
                
            }
        }];
    
}

- (void)_writeImageAsGIF:(NSArray *)images
                  toPath:(NSString*)path
                    size:(CGSize)size
                     fps:(int)fps
      animateTransitions:(BOOL)shouldAnimateTransitions
       withCallbackBlock:(VideoToImagesGifBlock)callbackBlock {
    
    [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    
    CGFloat secondsPerFrameFloat = 1 / fps;
    NSNumber * secondsPerFrame = [NSNumber numberWithFloat:secondsPerFrameFloat];
    
    NSDictionary * gifDict = [NSDictionary dictionaryWithObject:secondsPerFrame
                                                         forKey:( NSString *)kCGImagePropertyGIFDelayTime] ;
    
    NSDictionary *prep = [NSDictionary dictionaryWithObject:gifDict
                                                     forKey:(NSString *)kCGImagePropertyGIFDictionary];
    
    NSDictionary *fileProperties = @{
                                     (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0, // 0 means loop forever
                                             }
                                     };
    
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:path];
    
    CGImageDestinationRef dst = CGImageDestinationCreateWithURL(url, kUTTypeGIF, [images count], nil);
    CGImageDestinationSetProperties(dst, (__bridge CFDictionaryRef)fileProperties);
    
    for (int i=0;i<[images count];i++)
    {
        
        UIImage * anImage = [images objectAtIndex:i];
        
        CGImageDestinationAddImage(dst, anImage.CGImage,(__bridge CFDictionaryRef)(prep));
        
        /* //! implement animation stuff here
         if (shouldAnimateTransitions && i + 1 < [images count]) {
         UIImage * temp;
         
         NSInteger framesToFadeCount = AHIGIFTransitionFrameCount - AHIGIFFramesToWaitBeforeTransition;
         
         //Apply fade frames
         for (double j = 1; j < framesToFadeCount; j++) {
         UIImage * temp = [UIImage crossFadeImage:[array[i] CGImage]
         toImage:[array[i + 1] CGImage]
         atSize:size
         withAlpha:j/framesToFadeCount];
         
         CGImageDestinationAddImage(dst, temp.CGImage,(__bridge CFDictionaryRef)(prep));
         }
         
         
         }
         */
        
    }
    
    bool fileSave = CGImageDestinationFinalize(dst);
    CFRelease(dst);
    if(fileSave) {
        //        NSLog(@"animated GIF file created at %@", path);
        NSFileManager* manager = [NSFileManager defaultManager];
        //                        if ([manager fileExistsAtPath:urlString]){
        CGFloat gif = [[manager attributesOfItemAtPath:path error:nil] fileSize];
        
        NSLog(@" hehe%lf",gif);
        //                                }
    }else{
        NSLog(@"error: no animated GIF file created at %@", path);
    }
    MAIN(^{
        callbackBlock(path,nil);
    });
    
    //callbackBlock(fileSave ,path);
    
}


- (NSArray *) generateOffsets:(AVAsset *) asset
{
    
    
    double duration = CMTimeGetSeconds(asset.duration);
    
    
    NSMutableArray *indexes = [NSMutableArray array];
    
    double time = 0.0f;
    
    while (time < duration) {
        [indexes addObject:[NSNumber numberWithDouble:time]];
        time +=0.1;
    }
    [indexes removeLastObject];
    
    return indexes;
}

- (NSDictionary *) extractFromAssetAt:(NSArray *)indexes error:(NSError **)error duration:(CMTime)duration
{
    NSMutableDictionary *images = [NSMutableDictionary dictionaryWithCapacity:[indexes count]];
    NSLog(@"======总帧数：%li",[indexes count]);
    CMTime actualTime;
    
    for (NSNumber *number in indexes) {
        
        double offset = [number doubleValue];
        NSLog(@"%f",offset);
        if (offset < 0 || offset > CMTimeGetSeconds(duration)) {
            continue;
        }
        
        self.generator.requestedTimeToleranceBefore = kCMTimeZero;
        self.generator.requestedTimeToleranceAfter = kCMTimeZero;
        CMTime t = CMTimeMakeWithSeconds(offset, (int32_t)[indexes count]);
        CGImageRef source = [self.generator copyCGImageAtTime:t actualTime:nil error:error];
        
        if (!source) {
            NSLog(@"Error copying image at index %f: %@", CMTimeGetSeconds(actualTime), [*error localizedDescription]);
            return nil;
        }
        
        [images setObject:CFBridgingRelease(source) forKey:number];
    }
     
    
    return images;
}

- (UIImage *)imageWithLogoText:(UIImage *)img text:(NSString *)text1
{
    /////注：此为后来更改，用于显示中文。zyq,2013-5-8
    CGSize size = CGSizeMake(180, img.size.height);          //设置上下文（画布）大小
    UIGraphicsBeginImageContext(size);                       //创建一个基于位图的上下文(context)，并将其设置为当前上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext(); //获取当前上下文
    CGContextTranslateCTM(contextRef, 0, img.size.height);   //画布的高度
    CGContextScaleCTM(contextRef, 1.0, -1.0);                //画布翻转
    CGContextDrawImage(contextRef, CGRectMake(0, 0, img.size.width, img.size.height), [img CGImage]);  //在上下文种画当前图片
    
    [[UIColor lightTextColor] set];                                //上下文种的文字属性
    CGContextTranslateCTM(contextRef, 0, img.size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    UIFont *font = [UIFont boldSystemFontOfSize:13];
    CGSize textSize = [self TextSize:text1 Font:13];
    //    [text1 drawInRect:CGRectMake(img.size.width -textSize.width, img.size.height-textSize.height, textSize.width,textSize.height) withFont:font];       //此处设置文字显示的位置
    [text1 drawInRect:CGRectMake(img.size.width -textSize.width, img.size.height-textSize.height, textSize.width,textSize.height)  withAttributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,[UIColor lightTextColor],NSForegroundColorAttributeName,nil]];
    UIImage *targetimg =UIGraphicsGetImageFromCurrentImageContext();  //从当前上下文种获取图片
    UIGraphicsEndImageContext();                            //移除栈顶的基于当前位图的图形上下文。
    return targetimg;
}

-(CGSize )TextSize:(NSString *)text Font:(int )font
{
    UIFont *labelfont=[UIFont boldSystemFontOfSize:font];
    CGSize TextSize = [text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:labelfont,NSFontAttributeName,nil]];
    
    return TextSize;
}
@end
