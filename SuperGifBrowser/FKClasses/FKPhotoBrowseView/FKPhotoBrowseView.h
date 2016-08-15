//
//  FKPhotoBrowseView.h
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/30.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FKPhotoBrowseView;
@protocol FKPhotoBrowseViewDelegate <NSObject>

@required
- (NSInteger)numberOfItemsInFKPhotoBrowseView:(FKPhotoBrowseView *)collectionView;

- (UIImage *)collectionView:(UICollectionView *)collectionView imageForItemAtIndex:(NSInteger)index;
@end

@interface FKPhotoBrowseView : UICollectionView
@property(nonatomic,weak)id<FKPhotoBrowseViewDelegate> fkDelegate;
-(void)showFromIndex:(NSInteger)fromIndex;
-(void)dismiss;
@end
