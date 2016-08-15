//
//  MainViewController.h
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/24.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface MainViewController : UIViewController
//选择过滤
@property (nonatomic, strong) NSPredicate *selectionFilter;

//资源过滤
@property (nonatomic, strong) ALAssetsFilter *assetsFilter;

//选中的项
@property (nonatomic, strong) NSMutableArray *indexPathsForSelectedItems;

//最多选择项
//@property (nonatomic, assign) NSInteger maximumNumberOfSelection;

//最少选择项
//@property (nonatomic, assign) NSInteger minimumNumberOfSelection;

//显示空相册
@property (nonatomic, assign) BOOL showEmptyGroups;

//是否开启多选
@property (nonatomic, assign) BOOL multipleSelection;
@end
