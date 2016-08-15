//
//  LeftViewController.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/25.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import "AppDelegate.h"
#import "LeftViewController.h"

@interface LeftViewController ()

@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (IBAction)defaultShowVC:(UIButton *)sender {
    UIApplication *app = [UIApplication sharedApplication];
    AppDelegate *appDelegate = app.delegate;
    [appDelegate setMainControllerCenter];
}

- (IBAction)showHttpVC:(UIButton *)sender {
    UIApplication *app = [UIApplication sharedApplication];
    AppDelegate *appDelegate = app.delegate;
    [appDelegate setHttpControllerCenter];
}
- (IBAction)showLocalPhoto:(UIButton *)sender {
    UIApplication *app = [UIApplication sharedApplication];
    AppDelegate *appDelegate = app.delegate;
    [appDelegate setLocalControllerCenter];

}

- (IBAction)showWebViewController:(UIButton *)sender {
    UIApplication *app = [UIApplication sharedApplication];
    AppDelegate *appDelegate = app.delegate;
    [appDelegate setWebViewControllerCenter];
}

@end
