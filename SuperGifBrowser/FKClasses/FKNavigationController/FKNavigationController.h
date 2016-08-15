//
//  FKNavigationController.h
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/28.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FKNavigationController : UINavigationController
<
UIGestureRecognizerDelegate,
UINavigationControllerDelegate
>

// Enable the drag to back interaction, Default is YES.
@property (nonatomic,assign) BOOL canDragBack;

// UItableView Can Diag, Default is YES.
@property (nonatomic,assign) BOOL tableViewCanDrag;

@end
