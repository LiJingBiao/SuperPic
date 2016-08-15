//
//  FKVideoChooseCell.m
//  SuperGifBrowser
//
//  Created by LiJingBiao on 16/4/13.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//

#import "FKVideoChooseCell.h"

@interface FKVideoChooseCell()
@property (weak, nonatomic) IBOutlet UIImageView *imageBG;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;

@end

@implementation FKVideoChooseCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setAsset:(ALAsset *)asset
{
    if (_asset != asset) {
        _asset = asset;
        self.imageBG.image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
        double value = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        _durationLabel.text = [self timeFormatted:value];

    }
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
