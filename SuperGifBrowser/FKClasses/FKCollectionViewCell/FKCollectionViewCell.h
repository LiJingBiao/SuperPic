//
//  FKCollectionViewCell.h
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/28.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import "YYWebImage.h"
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface FKCollectionViewCellModel : NSObject
@property(nonatomic,assign)BOOL isSelectedButton;
@property (strong, nonatomic) ALAsset *photoAsset;
@property (copy, nonatomic) NSString *photoPath;
@end


@interface FKCollectionViewCell : UICollectionViewCell
@property(nonatomic,assign)BOOL showSelectedButton;
@property (weak, nonatomic) IBOutlet YYAnimatedImageView *photoImageView;
@property(nonatomic,weak) FKCollectionViewCellModel *fkCellModel;
-(void)setButtonSelelcted;
@end
