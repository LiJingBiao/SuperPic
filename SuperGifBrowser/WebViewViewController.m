//
//  WebViewViewController.m
//  SuperGifBrowser
//
//  Created by LiJingBiao on 16/3/26.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import "YYImage.h"
#import "PhotoBroswerVC.h"
#import "MMDrawerController+Subclass.h"
#import "UIViewController+MMDrawerController.h"
#import "WebViewViewController.h"

@interface WebViewViewController ()<UIWebViewDelegate,PhotoBroswerVCdelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property(nonatomic,strong)NSMutableArray *pathArray;
@property(nonatomic,assign)NSUInteger selectedIndex;
@property(nonatomic,assign)BOOL isInsertScript;
@end

@implementation WebViewViewController
- (IBAction)backAction:(UIButton *)sender {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.scrollView.alwaysBounceHorizontal = NO;
    self.webView.scrollView.decelerationRate = 1;
    NSString *userAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.116 Safari/537.36";
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:userAgent, @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    NSString *urlStr = @"http://www.baidu.com";
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.webView.scrollView.panGestureRecognizer addTarget:self action:@selector(scrollHandlePan:)];
    self.webView.delegate = self;
    _pathArray = [[NSMutableArray alloc]initWithCapacity:20];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.webView addGestureRecognizer:tap];
    tap.delegate = self;
    tap.cancelsTouchesInView = NO;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    [self insertJavaScript];
    return NO;
}
-(void)tapAction:(UITapGestureRecognizer *)tap
{
    CGPoint pt = [tap locationInView:self.webView];
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
    NSString *urlToSave = [self.webView stringByEvaluatingJavaScriptFromString:imgURL];
    NSLog(@"image url=%@", urlToSave);
    
    NSLog(@"点击了");
}
//传递滑动事件给下一层
-(void)scrollHandlePan:(UIPanGestureRecognizer*) panParam
{
    //当滑道左边界时，传递滑动事件给代理
    if(self.webView.scrollView.contentOffset.x <= 0) {
        [self.mm_drawerController panGestureCallback:panParam];
    }
    /*
    else if(_rootScrollView.contentOffset.x >= _rootScrollView.contentSize.width - _rootScrollView.bounds.size.width) {
        }
     */
}
- (IBAction)showMenuAction:(UIButton *)sender {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //预览图片
    if ([request.URL.scheme isEqualToString:@"image-preview"]) {
        NSString* path = [request.URL.absoluteString substringFromIndex:[@"image-preview:" length]];
        path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        path = [path lastPathComponent];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        //NSLog(@"documentsDirectory%@",documentsDirectory);
        NSString *gifDirectory = [documentsDirectory stringByAppendingPathComponent:@"GIF"];
        NSString *fileName = [gifDirectory stringByAppendingPathComponent:path];
        [self.pathArray removeAllObjects];
        [self.pathArray addObject:fileName];
        self.selectedIndex = 0;
        self.selectedIndex = [self.pathArray indexOfObject:fileName];
        PhotoBroswerVC *photoVC = [[PhotoBroswerVC alloc]initShow:self index:self.selectedIndex pageCount:self.pathArray.count];
        photoVC.delegate = self;
        [photoVC show];
        return NO;
       
    }
      
    return YES;
}
-(void)insertJavaScript
{
    NSString *str = [self.webView stringByEvaluatingJavaScriptFromString:@"typeof assignImageClickAction"];
    if (!self.isInsertScript || [str isEqualToString:@"undefined"]) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"function assignImageClickAction(){var imgs=document.getElementsByTagName('img');var length=imgs.length;for(var i=0;i<length;i++){img=imgs[i];img.lazyloaded='false';img.onclick=function(){window.location.href='image-preview:'+this.src}}}"];
        
        NSString *javaScript = @"function getAllPicSrc(){var imgs=document.getElementsByTagName('img');var length=imgs.length;var picSrcArray = new Array();for(var i=0;i<length;i++){img=imgs[i];picSrcArray.push(img.src);}return picSrcArray.toString();}";
        //NSLog(@"%@",javaScript);
        [self.webView stringByEvaluatingJavaScriptFromString:javaScript];
        [self.webView stringByEvaluatingJavaScriptFromString:@"assignImageClickAction();"];
        self.isInsertScript = YES;
    }else{
        NSLog(@"------:%@",str);
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self insertJavaScript];
}
-(NSString *)getImagePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *gifDirectory = [documentsDirectory stringByAppendingPathComponent:@"GIF"];
    return gifDirectory;
    
}
-(NSUInteger)totalShowImageCount
{
    return self.pathArray.count;
}

-(int)fromeIndex
{
    return self.selectedIndex;
}

-(PhotoModel *)getPhotoModelFromIndex:(NSUInteger)index
{
    PhotoModel *pbModel=[[PhotoModel alloc] init];
    pbModel.mid = index + 1;
    YYImage *image = [YYImage imageWithContentsOfFile:self.pathArray[index]];
    pbModel.image = image;
    pbModel.sourceImageView = nil;
    if (self.selectedIndex == index) {
        //pbModel.isFromSourceFrame = YES;
    }
    return pbModel;
}
@end
