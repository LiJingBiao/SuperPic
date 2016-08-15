//
//  LocalPhotoCollectionViewCell.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/25.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import "YYImage.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "AJPhotoListCellTapView.h"
#import "AJGradientView.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
#import "LocalPhotoCollectionViewCell.h"

@interface LocalPhotoCollectionViewCell ()
@property (weak, nonatomic) AJPhotoListCellTapView *tapAssetView;
@property (weak, nonatomic) AJGradientView *gradientView;
@end

@implementation LocalPhotoCollectionViewCell
- (void)setPhotoImage:(UIImage *)localPhotoImage {
    if (self.imageView == nil) {
        YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [self.contentView addSubview:imageView];
        self.imageView = imageView;
        
        [self.imageView setContentMode:UIViewContentModeScaleAspectFill];
        self.imageView.layer.cornerRadius = 3;
        self.imageView.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    
    if (!self.tapAssetView) {
        AJPhotoListCellTapView *tapView = [[AJPhotoListCellTapView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [self.contentView addSubview:tapView];
        self.tapAssetView = tapView;
    }
    
    [self.imageView setImage:localPhotoImage];
}

- (void)isSelected:(BOOL)isSelected {
    _tapAssetView.selected = isSelected;
}

#pragma mark - Utility
//时间格式化
- (NSString *)timeFormatted:(double)totalSeconds {
    NSTimeInterval timeInterval = totalSeconds;
    long seconds = lroundf(timeInterval); // Modulo (%) operator below needs int or long
    int hour = 0;
    int minute = seconds / 60.0f;
    int second = seconds % 60;
    if (minute > 59) {
        hour = minute / 60;
        minute = minute % 60;
        return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
    } else {
        return [NSString stringWithFormat:@"%02d:%02d", minute, second];
    }
}
@end
