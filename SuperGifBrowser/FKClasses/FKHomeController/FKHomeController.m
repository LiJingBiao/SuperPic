//
//  FKHomeController.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/4/6.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import "WKProgressHUD.h"
#import "GifGenerator.h"
#import "HttpViewController.h"
#import "FKMyCacheController.h"
#import "FKNavigationController.h"
#import "FKMainController.h"
#import "FKMyGifController.h"
#import "FKWebViewController.h"

#import "QRViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "FKVideoChooseController.h"

#import "FKHomeController.h"
#import "ShootVideoViewController.h"
@interface FKHomeController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *photoImageHeightC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loveImageHeightC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wifiButtonHeightC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *qrCodeButtonHeightC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *generatorButtonHeightC;

@end

@implementation FKHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:236.0/255.0 green:66.0/255.0 blue:67.0/255.0 alpha:1.0]];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat photoHeight = 150/320.*screenWidth-40;
    self.photoImageHeightC.constant = photoHeight;
    CGFloat otherHeight = (screenHeight - photoHeight - 25-64)/4.;
    self.loveImageHeightC.constant = self.wifiButtonHeightC.constant =self.generatorButtonHeightC.constant= self.qrCodeButtonHeightC.constant = otherHeight;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"表情利器";
    [self.navigationController.navigationBar setTitleTextAttributes:
  @{NSFontAttributeName:[UIFont systemFontOfSize:19],
    NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //NSString *path = [[NSBundle mainBundle]pathForResource:@"IMG_4132.MOV" ofType:nil];
    
    /*
    [WKProgressHUD showInView:self.view withText:@"正在生成GIF" animated:YES];
    [[GifGenerator shared]buildGifWithVideoPath:path VideoToImagesGifBlock:^(NSString *VideoToImagesGifPath, NSError *error) {
        [WKProgressHUD dismissInView:self.view animated:YES];
        NSLog(@"VideoToImagesGifPath:%@",VideoToImagesGifPath);
    }];
    */
    //NSTimer *timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(time_test) userInfo:nil repeats:YES];
    //[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}
-(void)time_test
{
    static int counter;
    //NSLog(@"=============:%d",counter++);
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
- (IBAction)photoButtonAction:(UIButton *)sender {
    FKMainController *photoVC = [FKMainController new];
    [self.navigationController pushViewController:photoVC animated:YES];
}
- (IBAction)loveButtonAction:(UIButton *)sender {
    FKMyGifController *myGif = [FKMyGifController new];
    [self.navigationController pushViewController:myGif animated:YES];
}
- (IBAction)exploreButtonAction:(UIButton *)sender {
    FKWebViewController *web = [FKWebViewController new];
    [self.navigationController pushViewController:web animated:YES];
}
- (IBAction)wifiButtonAction:(UIButton *)sender {
    HttpViewController *http = [HttpViewController new];
    [self.navigationController pushViewController:http animated:YES];
}

- (IBAction)itunesButtonAction:(UIButton *)sender {
    FKMyCacheController *cache = [FKMyCacheController new];
    [self.navigationController pushViewController:cache animated:YES];
}
- (IBAction)qrcodeButtonAction:(UIButton *)sender {
    [self openQR:nil];
}
- (IBAction)cacheButtonAction:(UIButton *)sender {
    FKMyCacheController *cache = [FKMyCacheController new];
    cache.isFromMyCache = YES;
    [self.navigationController pushViewController:cache animated:YES];
}
- (IBAction)creatGifAction:(UIButton *)sender {
    //FKVideoChooseController *choose = [FKVideoChooseController new];
    //[self.navigationController pushViewController:choose animated:YES];
    
    ShootVideoViewController *shoot = [ShootVideoViewController new];
    [self.navigationController pushViewController:shoot animated:YES];
}



- (void)openQR:(id)sender {
    
    if ([self validateCamera] && [self canUseCamera]) {
        
        [self showQRViewController];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有摄像头或摄像头不可用" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(BOOL)canUseCamera {
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        NSLog(@"相机权限受限");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请在设备的设置-隐私-相机中允许访问相机。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }
    
    return YES;
}

-(BOOL)validateCamera {
    
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] &&
    [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}


- (void)showQRViewController {
    
    QRViewController *qrVC = [[QRViewController alloc] init];
    [self.navigationController pushViewController:qrVC animated:YES];
}

@end
