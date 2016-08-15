//
//  GifURLProtocol.m
//  SuperGifBrowser
//
//  Created by LiJingBiao on 16/3/26.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//

#import "GifURLProtocol.h"
#import "FKFileManager.h"
#import <UIKit/UIKit.h>
#define protocolKey @"GifProtocolKey"

@interface GifURLProtocol ()
{
    int totalCount;
}
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic,assign)BOOL isPic;
@property (nonatomic, strong) NSURLConnection * connection;
@property (nonatomic, copy) NSString *picName;

@end

@implementation GifURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    
    /*
     防止无限循环，因为一个请求在被拦截处理过程中，也会发起一个请求，这样又会走到这里，如果不进行处理，就会造成无限循环
     */
    if ([NSURLProtocol propertyForKey:protocolKey inRequest:request]) {
        return NO;
    }
    
    NSString * url = request.URL.absoluteString;
    
    // 如果url已http或https开头，则进行拦截处理，否则不处理
    if ([url hasPrefix:@"http"] || [url hasPrefix:@"https"]) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    
    return request;

}
- (void)startLoading {
    NSMutableURLRequest * request = [self.request mutableCopy];
    NSString *urlStr = request.URL.absoluteString;

    NSString *pathExt = [[urlStr pathExtension]lowercaseString];

    /*
    if ([pathExt rangeOfString:@"jpg"].location!=NSNotFound||[pathExt rangeOfString:@"jpeg"].location!=NSNotFound||[pathExt rangeOfString:@"gif"].location!=NSNotFound||[pathExt rangeOfString:@"png"].location!=NSNotFound) {
        //NSLog(@"=========%@",urlStr);
        self.isPic = YES;
        self.picName = [urlStr lastPathComponent];
    }
     */
    self.isPic = YES;
    self.picName = [urlStr lastPathComponent];
    // 表示该请求已经被处理，防止无限循环
    [NSURLProtocol setProperty:@(YES) forKey:protocolKey inRequest:request];
    
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
    //NSLog(@"%d",++totalCount);
}

- (void)stopLoading {
    [self.connection cancel];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    if (self.isPic) {
        [self appendData:data];
    }

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *webCacheDirectory =[FKFileManager webCachePath];
    NSString *fileName = [webCacheDirectory stringByAppendingPathComponent:self.picName];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:fileName isDirectory:&isDir]){
        UIImage *image = [UIImage imageWithData:self.data];
        NSString *imageType = [self mimeTypeByGuessingFromData:self.data];
        NSLog(@"imageType:%@",imageType);
        if (image.size.width>5) {
           [self.data writeToFile:fileName atomically:YES];
        }
        self.data = nil;
        //NSLog(@"不存在");
    }else{
        //NSLog(@"存在");
        self.data = nil;
    }

}

- (NSString *)mimeTypeByGuessingFromData:(NSData *)data {
    
    char bytes[12] = {0};
    [data getBytes:&bytes length:12];
    
    const char bmp[2] = {'B', 'M'};
    const char gif[3] = {'G', 'I', 'F'};
    const char swf[3] = {'F', 'W', 'S'};
    const char swc[3] = {'C', 'W', 'S'};
    const char jpg[3] = {0xff, 0xd8, 0xff};
    const char psd[4] = {'8', 'B', 'P', 'S'};
    const char iff[4] = {'F', 'O', 'R', 'M'};
    const char webp[4] = {'R', 'I', 'F', 'F'};
    const char ico[4] = {0x00, 0x00, 0x01, 0x00};
    const char tif_ii[4] = {'I','I', 0x2A, 0x00};
    const char tif_mm[4] = {'M','M', 0x00, 0x2A};
    const char png[8] = {0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a};
    const char jp2[12] = {0x00, 0x00, 0x00, 0x0c, 0x6a, 0x50, 0x20, 0x20, 0x0d, 0x0a, 0x87, 0x0a};
    
    
    if (!memcmp(bytes, bmp, 2)) {
        return @"image/x-ms-bmp";
    } else if (!memcmp(bytes, gif, 3)) {
        return @"image/gif";
    } else if (!memcmp(bytes, jpg, 3)) {
        return @"image/jpeg";
    } else if (!memcmp(bytes, psd, 4)) {
        return @"image/psd";
    } else if (!memcmp(bytes, iff, 4)) {
        return @"image/iff";
    } else if (!memcmp(bytes, webp, 4)) {
        return @"image/webp";
    } else if (!memcmp(bytes, ico, 4)) {
        return @"image/vnd.microsoft.icon";
    } else if (!memcmp(bytes, tif_ii, 4) || !memcmp(bytes, tif_mm, 4)) {
        return @"image/tiff";
    } else if (!memcmp(bytes, png, 8)) {
        return @"image/png";
    } else if (!memcmp(bytes, jp2, 12)) {
        return @"image/jp2";
    }
    
    return nil; // default type
    
}

- (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
    if (self.isPic) {
        [self appendData:nil];
    }

}

- (void)appendData:(NSData *)newData
{
    if ([self data] == nil) {
        [self setData:[newData mutableCopy]];
    }
    else {
        [[self data] appendData:newData];
    }
}
@end
