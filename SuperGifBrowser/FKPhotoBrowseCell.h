//
//  FKPhotoBrowseCell.h
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/30.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import "YYWebImage.h"
#import <UIKit/UIKit.h>
extern NSString *dismissNotification;
@interface FKPhotoBrowseCell : UICollectionViewCell
@property(nonatomic,strong) YYAnimatedImageView *photoImageView;
- (void)resizeSubviewSize;
@end
