//
//  FKNavigationController.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/28.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//

#define KEY_WINDOW  [[UIApplication sharedApplication]keyWindow]
#define kBackViewWidth [UIScreen mainScreen].bounds.size.width
#define kBackViewHeight [UIScreen mainScreen].bounds.size.height

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#import "FKNavigationController.h"
#import <QuartzCore/QuartzCore.h>

@interface FKNavigationController ()
{
    CGPoint startTouch;
    
    UIImageView *lastScreenShotView;
    UIView *blackMask;
    BOOL bAllowDebug;
}

@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) NSMutableArray *screenShotsList;
@property (nonatomic, strong) UIPanGestureRecognizer *interactiveGestureRecognizer;

@property (nonatomic,assign) BOOL isMoving;
@end

@implementation FKNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        //        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
        //        {
        //            self.interactivePopGestureRecognizer.enabled = YES;
        //        }
        //        else
        {
            self.interactivePopGestureRecognizer.enabled = NO;
            self.screenShotsList = [[NSMutableArray alloc] initWithCapacity:2];
            self.canDragBack = YES;
            self.tableViewCanDrag = YES;
        }
    }
    return self;
}

- (void)dealloc
{
    //    if (![self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    self.screenShotsList = nil;
    
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    //    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationBar.translucent = NO;
    __weak FKNavigationController *weakSelf = self;
    self.delegate = weakSelf;
    
    //    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    //        [self.interactivePopGestureRecognizer addTarget:self action:@selector(interactiveGestureReceive:)];
    //        self.interactivePopGestureRecognizer.delegate = weakSelf;
    //    }
    //    else
    {
        UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_leftside_shadow"]];
        shadowImageView.frame = CGRectMake(-10, 0, 10, self.view.frame.size.height);
        [self.view addSubview:shadowImageView];
        
        _interactiveGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(paningGestureReceive:)];
        [_interactiveGestureRecognizer setMaximumNumberOfTouches:1];
        _interactiveGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:_interactiveGestureRecognizer];
    }
    

}

// override the push method
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    //        self.interactivePopGestureRecognizer.enabled = NO;
    //    }
    //    else
    {
        self.interactiveGestureRecognizer.enabled = NO;
        UIImage *image=[self capture];
        if (image) {
            [self.screenShotsList addObject:image];
        }
    }
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    [super pushViewController:viewController animated:animated];
}

// override the pop method
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    //    if (![self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    [self.screenShotsList removeLastObject];
    //    }
    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    return [super popViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //    if (![self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    NSUInteger index = self.viewControllers.count - [self.viewControllers indexOfObject:viewController];
    for (int i = 1; i< index; i++)
    {
        [self.screenShotsList removeLastObject];
    }
    //    }
    
    return [super popToViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    //    if (![self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    [self.screenShotsList removeAllObjects];
    //    }
    
    return [super popToRootViewControllerAnimated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    //    {
    if ([[navigationController.viewControllers firstObject] isEqual:viewController])
    {
        self.interactiveGestureRecognizer.enabled = NO;
        //            navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    else
    {
        self.interactiveGestureRecognizer.enabled = YES;
        //            navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
    //    }
}

#pragma mark - Utility Methods -

// get the current view screen shot
- (UIImage *)capture
{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
    
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

// set lastScreenShotView 's position and alpha when paning
- (void)moveViewWithX:(float)x
{
    //TCLog(@"iiiiiiiiii move OrignX is %f",x);
    
    x = x>kBackViewWidth?kBackViewWidth:x;
    x = x<0?0:x;
    
    CGRect frame = self.view.frame;
    frame.origin.x = x;
    self.view.frame = frame;
    
    float alpha = 0.4 - (x/800);
    
    blackMask.alpha = alpha;
    
    CGFloat scale = abs(80) / kBackViewWidth;
    CGFloat y = x * scale;
    
    CGFloat lastScreenShotViewHeight = kBackViewHeight;
    
    [lastScreenShotView setFrame:CGRectMake(-80+y,
                                            0,
                                            kBackViewWidth,
                                            lastScreenShotViewHeight)];
}

#pragma mark - Gesture Recognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    // If the viewControllers has only one vc or disable the interaction, then return.
    if (self.viewControllers.count <= 1) return NO;
    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"])
    {
        return self.tableViewCanDrag;
    }
    
    if ([NSStringFromClass([touch.view class]) isEqualToString:@"PriceTendView"]
        || [NSStringFromClass([touch.view class]) isEqualToString:@"TCSlider"]
        || [NSStringFromClass([touch.view class]) isEqualToString:@"BATableViewIndex"]
        || [NSStringFromClass([touch.view class]) isEqualToString:@"UISwitch"])
    {
        return NO;
    }
    return self.canDragBack;
}

- (void)interactiveGestureReceive:(UIGestureRecognizer *)recoginzer
{
    UIViewController *viewController = [self.viewControllers lastObject];
    SEL selector = @selector(navigationDragBackClearData);
    if ([viewController respondsToSelector:selector])
    {
        SuppressPerformSelectorLeakWarning(
                                           [viewController performSelector:selector withObject:nil];
                                           );
    }
}

- (void)paningGestureReceive:(UIPanGestureRecognizer *)recoginzer
{
    
    // we get the touch position by the window's coordinate
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    if (recoginzer.state == UIGestureRecognizerStateBegan)
    {
        //滑动限制，左边80才可返回
        CGPoint startPoint = [recoginzer locationInView:self.view];
        if (startPoint.x > 100) return;
        if (!self.canDragBack) return;
        
        //TCLog(@"!!!!!move step is 0 %d",recoginzer.state);
        _isMoving = YES;
        startTouch = touchPoint;
        
        if (!self.backgroundView)
        {
            CGRect frame = self.view.frame;
            
            self.backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            [self.view.superview insertSubview:self.backgroundView belowSubview:self.view];
            
            blackMask = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width , frame.size.height)];
            blackMask.backgroundColor = [UIColor blackColor];
            [self.backgroundView addSubview:blackMask];
        }
        
        self.backgroundView.hidden = NO;
        
        if (lastScreenShotView) [lastScreenShotView removeFromSuperview];
        
        UIImage *lastScreenShot = [self.screenShotsList lastObject];
        //        UIImage *lastScreenShot = [UIImage imageNamed:@"Default-568h"];
        lastScreenShotView = [[UIImageView alloc]initWithImage:lastScreenShot];
        [self.backgroundView insertSubview:lastScreenShotView belowSubview:blackMask];
    }
    else if (recoginzer.state == UIGestureRecognizerStateEnded  ||
             recoginzer.state == UIGestureRecognizerStateCancelled)
    {
        //TCLog(@"!!!!!move step is 1 %d",recoginzer.state);
        if (_isMoving) {
            if (touchPoint.x - startTouch.x > 100)
            {
                //TCLog(@"!!!!!move step is 2 %d",recoginzer.state);
                
                [UIView animateWithDuration:0.3 animations:^{
                    [self moveViewWithX:kBackViewWidth];
                } completion:^(BOOL finished) {
                    
                    UIViewController *viewController = [self.viewControllers lastObject];
                    SEL selector = @selector(navigationDragBack:);
                    if ([viewController respondsToSelector:selector])
                    {
                        SuppressPerformSelectorLeakWarning(
                                                           [viewController performSelector:selector withObject:(BOOL)NO];
                                                           );
                    }
                    else
                    {
                        [self popViewControllerAnimated:NO];
                    }
                    CGRect frame = self.view.frame;
                    frame.origin.x = 0;
                    self.view.frame = frame;
                    
                    _isMoving = NO;
                    
                    CATransition *transition = [CATransition animation];
                    transition.duration = 0.3f;
                    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    transition.type = kCATransitionFade;
                    self.backgroundView.hidden = YES;
                    [self.view.superview.layer addAnimation:transition forKey:nil];
                    
                }];
            }
            else
            {
                //TCLog(@"!!!!!move step is 3 %d",recoginzer.state);
                
                [UIView animateWithDuration:0.3 animations:^{
                    [self moveViewWithX:0];
                } completion:^(BOOL finished) {
                    _isMoving = NO;
                    self.backgroundView.hidden = YES;
                }];
                
            }
        }
        else {
            if (self.view.frame.origin.x != 0) {
                [UIView animateWithDuration:0.3 animations:^{
                    [self moveViewWithX:0];
                } completion:^(BOOL finished) {
                    _isMoving = NO;
                    self.backgroundView.hidden = YES;
                }];
            }
        }
    }
    else if (recoginzer.state == UIGestureRecognizerStateChanged)
    {
        //TCLog(@"!!!!!move step is 4 %d",recoginzer.state);
        if (_isMoving)
        {
            [self moveViewWithX:touchPoint.x - startTouch.x];
        }
    }
    else
    {
        //TCLog(@"!!!!!move step is 5 %d",recoginzer.state);
        
        [UIView animateWithDuration:0.3 animations:^{
            [self moveViewWithX:0];
        } completion:^(BOOL finished) {
            _isMoving = NO;
            self.backgroundView.hidden = YES;
        }];
    }
    // TCLog(@"!!!!!move Recognizer State is %d,moving is %@",recoginzer.state,_isMoving?@"YES":@"NO");
}


@end
