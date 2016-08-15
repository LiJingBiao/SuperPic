//
//  FKWebViewController.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/31.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import "WKProgressHUD.h"
#import "FKFileManager.h"
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"
#import "FKWebViewController.h"


typedef NS_ENUM(NSUInteger, FKWebViewDirection) {
    FKWebViewDirectionNone = 0,
    FKWebViewDirectionUp,
    FKWebViewDirectionDown,
};

@interface FKWebViewController ()<UITextFieldDelegate,UIWebViewDelegate, NJKWebViewProgressDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate>
{
    BOOL isDrag;
    BOOL isLoading;
}

@property (assign, nonatomic) FKWebViewDirection direction;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet NJKWebViewProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *titleButton;
@property (weak, nonatomic) IBOutlet UIView *navgationView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navHeightC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftMarginC;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightMarginConstraint;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMarginC;
@property (weak, nonatomic) IBOutlet UIView *navgationContentBG;

@property (strong, nonatomic) NJKWebViewProgress *progressProxy;
@property(nonatomic,copy) NSString *saveImageURL;
@property(nonatomic,copy)NSString *longPressImageUrl;
@property (strong, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation FKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _direction = 0;
    self.navigationController.navigationBar.hidden = YES;
    self.textField.delegate =self;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    
    NSURL *url;
    if (self.urlStr.length) {
        url = [NSURL URLWithString:self.urlStr];
    }else{
        url = [NSURL URLWithString:@"http://md.itlun.cn/"];
        //NSString *urlStr = @"http://toutiao.com/group/6272825389489307905/?iid=3820070519&app=news_article&tt_from=mobile_qq&utm_source=mobile_qq&utm_medium=toutiao_ios&utm_campaign=client_share";
        //url = [NSURL URLWithString:urlStr];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    self.webView.scrollView.decelerationRate =1;
    self.webView.scrollView.delegate = self;
    
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
    //longPress.minimumPressDuration = 0.3;
    [self.webView addGestureRecognizer:longPress];
    longPress.delegate = self;
    longPress.cancelsTouchesInView = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.backButton];
}

- (IBAction)backButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //[self insertJavaScript];
    return YES;
}
-(void)longPressAction:(UILongPressGestureRecognizer *)longPress
{
    
    if(longPress.state == UIGestureRecognizerStateBegan) {
        
        CGPoint pt = [longPress locationInView:self.webView];
        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
        NSString *urlToSave = [self.webView stringByEvaluatingJavaScriptFromString:imgURL];
        if (!urlToSave) {
            return;
        }
        self.saveImageURL = urlToSave;
        NSLog(@"image url=%@", urlToSave);
        UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存图片",@"分享到微信",@"分享到QQ", nil];
        [sheet showInView:self.view];
        NSLog(@"点击了");
        
    }
    
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.webView.userInteractionEnabled = NO;
    _rightMarginConstraint.constant = 50;
    [UIView animateWithDuration:0.15 animations:^{
        [self.view layoutIfNeeded];
    }];
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.webView.userInteractionEnabled = YES;
    _rightMarginConstraint.constant = 10;
    [UIView animateWithDuration:0.15 animations:^{
        [self.view layoutIfNeeded];
    }];
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *urlStr =textField.text;
    NSURL *url;
    if ([urlStr hasPrefix:@"http://"] ||[urlStr hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:urlStr];
    }else{
        url = [NSURL URLWithString:[@"http://" stringByAppendingString:textField.text]];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    self.textField.text = url.absoluteString;
    [self.webView loadRequest:request];
    [textField resignFirstResponder];
    return YES;
}
- (IBAction)cancelAction:(UIButton *)sender {
    [self.textField resignFirstResponder];
    self.titleButton.hidden = NO;
    self.textField.hidden = YES;
    self.cancelButton.hidden = YES;

}
#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSString *currentURL = self.webView.request.URL.absoluteString;
    self.textField.text = currentURL;
    if (progress>=1.0) {
        isLoading = NO;
        self.titleButton.hidden = NO;
        [self.titleButton setTitle:self.title forState:UIControlStateNormal];
        self.textField.hidden = YES;
        self.cancelButton.hidden = YES;

    }else{
        isLoading = YES;
    }
    NSLog(@"%f",progress);
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    self.titleButton.hidden = YES;
    self.textField.hidden = NO;
    self.cancelButton.hidden = NO;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.titleButton.hidden = NO;
    [self.titleButton setTitle:self.title forState:UIControlStateNormal];
    self.textField.hidden = YES;
    self.cancelButton.hidden = YES;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    NSLog(@"Fuck error:%@",error);
}
int _lastPosition;
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int currentPostion = scrollView.contentOffset.y;
    if (currentPostion - _lastPosition > 25) {
        _lastPosition = currentPostion;
        _direction = FKWebViewDirectionUp;
    }
    else if (_lastPosition - currentPostion > 25)
    {
        _lastPosition = currentPostion;
        _direction = FKWebViewDirectionDown;
    }
    if (isLoading) {
        return;
    }
    if (isDrag == YES) {
        CGFloat Yoffset = scrollView.contentOffset.y;
        if (Yoffset>0&&Yoffset<32) {
            NSLog(@"--------");
            self.navHeightC.constant = 64 - Yoffset;
            CGFloat rate = (64-Yoffset)/64;
            CGFloat alphaRate = (20-Yoffset)/20;
            CGFloat leftMarginRate = Yoffset/20;
            if (leftMarginRate>1) {
                leftMarginRate = 1;
            }
            self.leftMarginC.constant = 10*leftMarginRate*5;
            self.rightMarginConstraint.constant = 10*leftMarginRate*5;
            self.titleButton.titleLabel.font = [UIFont systemFontOfSize:16*rate];
            if (Yoffset<16) {
                self.topMarginC.constant = 27*rate;
            }
            if (alphaRate < 0) {
                alphaRate = 0.;
            }
            self.navgationContentBG.backgroundColor = [UIColor colorWithRed:240./255. green:240./255. blue:240./255. alpha:alphaRate];
            //self.navgationView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, rate);
            //NSLog(@"yoffset:%f",Yoffset);
        }
    }
    

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isDrag = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    isDrag = NO;
    if (isLoading) {
        return;
    }

    if (decelerate) {
        if (_direction == FKWebViewDirectionUp) {
            NSLog(@"向上");
            self.navHeightC.constant = 32;
            self.leftMarginC.constant = 50;
            self.rightMarginConstraint.constant = 50;
            self.titleButton.titleLabel.font = [UIFont systemFontOfSize:8];
            self.topMarginC.constant = 27*0.75;
            self.navgationContentBG.backgroundColor = [UIColor colorWithRed:240./255. green:240./255. blue:240./255. alpha:0];
        }else if (_direction == FKWebViewDirectionDown){
            
            [self resetNavgationView];
            NSLog(@"向下");
        }
        
    }else{
        

    }
}

-(void)resetNavgationView
{
    self.navHeightC.constant = 64;
    self.leftMarginC.constant = 10;
    self.rightMarginConstraint.constant = 10;
    self.titleButton.titleLabel.font = [UIFont systemFontOfSize:16];
    self.topMarginC.constant = 27;
    self.navgationContentBG.backgroundColor = [UIColor colorWithRed:240./255. green:240./255. blue:240./255. alpha:1.];
}
- (IBAction)titleButtonAction:(UIButton *)sender {
    [self resetNavgationView];
    self.titleButton.hidden = YES;
    self.textField.hidden = NO;
    self.cancelButton.hidden = NO;
    [self.textField becomeFirstResponder];
}
- (IBAction)goBackAction:(UIButton *)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}
- (IBAction)reloadAction:(UIButton *)sender {
    [self.webView reload];
}

- (IBAction)forwardAction:(UIButton *)sender {
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}
#pragma mark actionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!self.saveImageURL.length) {
        return;
    }
    if (buttonIndex == 0 && self.saveImageURL.length) {
        NSString *lastPathComponent = [self.saveImageURL lastPathComponent];
        NSString *localImagePath = [FKFileManager imgPathInWebCacheWithName:lastPathComponent];
        if (localImagePath) {
            BOOL isSuccess = [FKFileManager copyItemPathToMyGifPathFromPath:localImagePath];
            if (isSuccess) {
                [WKProgressHUD popMessage:@"保存成功" inView:self.view duration:0.3 animated:YES];
            }else{
                [WKProgressHUD popMessage:@"保存失败" inView:self.view duration:0.3 animated:YES];
            }
        }
        self.saveImageURL = nil;
    }else if (buttonIndex == 1){
        NSString *lastPathComponent = [self.saveImageURL lastPathComponent];
        NSString *localImagePath = [FKFileManager imgPathInWebCacheWithName:lastPathComponent];
        if (localImagePath) {
           [FKShareManager shareImageWithData:[NSData dataWithContentsOfFile:localImagePath] isWX:YES];
        }
        self.saveImageURL = nil;
        
    }else if (buttonIndex == 2){
        NSString *lastPathComponent = [self.saveImageURL lastPathComponent];
        NSString *localImagePath = [FKFileManager imgPathInWebCacheWithName:lastPathComponent];
        if (localImagePath) {
            [FKShareManager shareImageWithData:[NSData dataWithContentsOfFile:localImagePath] isWX:NO];
        }
        self.saveImageURL = nil;
        
    }
    NSLog(@"%d",buttonIndex);
}
@end
