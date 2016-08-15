//
//  AppDelegate.h
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/24.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

-(void)setHttpControllerCenter;
-(void)setMainControllerCenter;
-(void)setLocalControllerCenter;
-(void)setWebViewControllerCenter;
@end

