//
//  FKCollectionView.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/28.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#define SCREEN_WIDTH  [[UIScreen mainScreen] applicationFrame].size.width
#import "FKCollectionView.h"
static const float kCellItemSpacing = 6.0;
static const float kCellLineSpacing = 7;
static const float kCellMarginSpacing = 11.0;//上下左右的距离
static const float kNumberOfRow = 3.0;//每行几个item
static NSString * const kCellIdentifier = @"DStrategyHotCollectionCell";

@implementation FKCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    
    CGFloat cellWidth;//UIcollectionView cell宽度
    cellWidth = (SCREEN_WIDTH - (kCellMarginSpacing * 2) - (kNumberOfRow-1) * kCellItemSpacing) / (kNumberOfRow *1.0);
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumInteritemSpacing = kCellItemSpacing;
    layout.minimumLineSpacing = kCellLineSpacing;
    layout.itemSize = CGSizeMake(cellWidth, cellWidth);//每个cell的大小
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
    }
    
    return self;
    
    
}

@end
