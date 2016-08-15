//
//  LocalPhotoCollectionViewCell.h
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/25.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import "YYWebImage.h"
#import <UIKit/UIKit.h>

@interface LocalPhotoCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) YYAnimatedImageView *imageView;
- (void)setPhotoImage:(UIImage *)localPhotoImage;
@end
