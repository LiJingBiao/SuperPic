//
//  FKPhotoBrowseView.h
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/29.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FKPhotoBrowseViewDelegate <NSObject>
@required
-(NSUInteger)fkPhotoBrowseViewCellCount;

-(UIImage *)fkPhotoBrowseViewCellImageIndex:(NSUInteger)index;

@end


@interface FKPhotoBrowseItem : NSObject
@property (nonatomic, strong) UIView *thumbView; ///< thumb image, used for animation position calculation
@property (nonatomic, assign) CGSize largeImageSize;
@property (nonatomic, strong) NSURL *largeImageURL;
@end


@interface FKPhotoBrowseView : UIView
//@property (nonatomic, readonly) NSArray *groupItems;
@property (nonatomic,weak) id<FKPhotoBrowseViewDelegate> delegate;
@end
