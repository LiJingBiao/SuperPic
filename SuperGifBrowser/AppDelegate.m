//
//  AppDelegate.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/24.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import <TencentOpenAPI/TencentOAuth.h>
#import "FKHomeController.h"
#import "WebViewViewController.h"
#import "LeftViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "MMDrawerController.h"
#import "HttpViewController.h"
#import "LocalViewController.h"
#import "GifURLProtocol.h"

#import "FKVideoChooseController.h"
#import "FKMyCacheController.h"
#import "FKNavigationController.h"
//#import "FKMainController.h"
//#import "FKMyGifController.h"
//#import "FKWebViewController.h"
#import "WXApi.h"
@interface AppDelegate ()<WXApiDelegate>
@property (nonatomic,strong) MMDrawerController * drawerController;
@property(nonatomic,strong) MainViewController *rootViewController;
@property(nonatomic,strong) LeftViewController *leftVc;
@property(nonatomic,strong) HttpViewController *httpVc;
@property(nonatomic,strong) LocalViewController *localPhotoVc;
@property(nonatomic,strong) WebViewViewController *webController;
@property(nonatomic,strong) FKVideoChooseController *videoChooseVC;
/*
@property(nonatomic,strong) FKMainController *fkMain;
@property(nonatomic,strong) FKMyGifController *fkMyGif;
@property(nonatomic,strong) FKWebViewController *fkWebVC;
@property(nonatomic,strong) FKMyCacheController *fkMyCache;
*/
@property(nonatomic,strong) FKMyCacheController *fkMyCache;
@property(nonatomic,strong) FKHomeController *fkHome;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [UIApplication sharedApplication].statusBarHidden = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    self.window.backgroundColor = [UIColor whiteColor];
    
    //[WXApi registerApp:@"wx73a779afcf9f37a4"];
    [WXApi registerApp:@"wxe03a93e304544ce2"];
    /*
    self.rootViewController = [[MainViewController alloc]init];
    self.leftVc = [[LeftViewController alloc]init];
    
    
    self.drawerController = [[MMDrawerController alloc]
                             initWithCenterViewController:self.rootViewController
                             leftDrawerViewController:self.leftVc
                             rightDrawerViewController:nil];
    [self.drawerController setShowsShadow:NO];
    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    [self.drawerController setMaximumRightDrawerWidth:200.0];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeAll];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    self.drawerController.view.backgroundColor = [UIColor whiteColor];
    [self.drawerController
     setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
     }];
     */
    //self.webController = [WebViewViewController new];
    //self.window.rootViewController = self.webController;
    //self.window.rootViewController = self.drawerController;
    
    /*
    self.fkMain = [FKMainController new];
    self.fkMyGif = [FKMyGifController new];
    self.fkWebVC = [FKWebViewController new];
    self.fkMyCache = [FKMyCacheController new];
     */
    //self.fkMyCache = [FKMyCacheController new];
    self.videoChooseVC = [FKVideoChooseController new];
    self.fkHome = [FKHomeController new];
    FKNavigationController *nav = [[FKNavigationController alloc]initWithRootViewController:self.fkHome];
    self.window.rootViewController = nav;
    
    [NSURLProtocol registerClass:[GifURLProtocol class]];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)setHttpControllerCenter
{
    if (!self.httpVc) {
        self.httpVc = [HttpViewController new];
    }
    [self.drawerController setCenterViewController:self.httpVc withCloseAnimation:YES completion:NULL];
}
-(void)setLocalControllerCenter
{
    if (!self.localPhotoVc) {
        self.localPhotoVc = [LocalViewController new];
    }
    [self.drawerController setCenterViewController:self.localPhotoVc withCloseAnimation:YES completion:NULL];
}
-(void)setMainControllerCenter
{
    [self.drawerController setCenterViewController:self.rootViewController withCloseAnimation:YES completion:NULL];
}

-(void)setWebViewControllerCenter
{
    if (!self.webController) {
        self.webController = [WebViewViewController new];
    }
    [self.drawerController setCenterViewController:self.webController withCloseAnimation:YES completion:NULL];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];

}

-(BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation{
    if ([sourceApplication hasSuffix:@"mqq"]) {
        [TencentOAuth HandleOpenURL:url];
    }
    return [WXApi handleOpenURL:url delegate:self];
}
/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
-(void) onReq:(BaseReq*)req
{
    NSLog(@"%@",req);
}



/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
-(void) onResp:(BaseResp*)resp
{
    NSLog(@"%d-----%@",resp.errCode,resp.errStr);
}
@end
