//
//  FKPhotoBrowseCell.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/30.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import "FKPhotoBrowseView.h"
#import "UIView+Ext.h"
#import "FKPhotoBrowseCell.h"
#define SCREEN_WIDTH  [[UIScreen mainScreen] applicationFrame].size.width

#ifndef YY_CLAMP // return the clamped value
#define YY_CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif

@interface FKPhotoBrowseCell()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    CFRunLoopRef runLoop;
    CFRunLoopObserverRef observer;
    BOOL isDismiss;
}
@property(nonatomic,strong) UIView *imageContainerView;
@property (nonatomic, assign) CGPoint panGestureBeginPoint;
@property (weak, nonatomic)FKPhotoBrowseView *browseView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@end

@implementation FKPhotoBrowseCell

- (void)awakeFromNib {
    self.scrollView.delegate = self;
    self.scrollView.bouncesZoom = YES;
    self.scrollView.maximumZoomScale = 3;
    self.scrollView.multipleTouchEnabled = YES;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    
    
    self.photoImageView = [[YYAnimatedImageView alloc]init];
    self.imageContainerView = [UIView new];
    _imageContainerView.clipsToBounds = YES;
    [self.imageContainerView addSubview:self.photoImageView];
    [self.scrollView addSubview:self.imageContainerView];
    self.contentView.backgroundColor = [UIColor clearColor];
    //self.imageContainerView.userInteractionEnabled = NO;

    //[self.scrollView.panGestureRecognizer addTarget:self action:@selector(pan:)];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    tap2.delegate = self;
    tap2.numberOfTapsRequired = 2;
    [tap requireGestureRecognizerToFail: tap2];
    [self addGestureRecognizer:tap2];
    
    runLoop = CFRunLoopGetCurrent();
    observer = CFRunLoopObserverCreateWithHandler
    (kCFAllocatorDefault, kCFRunLoopBeforeWaiting, true, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity _) {
        NSString *loopMode = [[NSRunLoop currentRunLoop] currentMode];
        [self removeRunLoopObserver];
        if ([loopMode isEqualToString:@"kCFRunLoopDefaultMode"]) {//闲置状态
            [self setBottomTools:YES];
        }else{
            [self setBottomTools:NO];
        }
    });
    self.bottomConstraint.constant = -44;
    [self observerRunLoop];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(observerAction) name:dismissNotification object:nil];
}

-(void)observerAction
{
    isDismiss = YES;
    [self removeRunLoopObserver];
}

-(void)setBottomTools:(BOOL)show
{
    NSInteger bottomC = (NSInteger)self.bottomConstraint.constant;
    if (show) {
        if (bottomC == 0) {
            [self observerRunLoop];
        }else{
            self.bottomConstraint.constant = 0;
            [UIView animateWithDuration:0.2 animations:^{
                [self.contentView layoutIfNeeded];
            } completion:^(BOOL finished) {
                [self observerRunLoop];
            }];
        }
    }else{
        if (bottomC == 0) {
            self.bottomConstraint.constant = -44;
            [UIView animateWithDuration:0.1 animations:^{
                [self.contentView layoutIfNeeded];
            } completion:^(BOOL finished) {
                [self observerRunLoop];
            }];
            
        }else{
            [self observerRunLoop];
        }
    }
}

-(void)observerRunLoop
{
    if (isDismiss)return;
    CFStringRef runLoopMode1 = kCFRunLoopDefaultMode;
    CFStringRef runLoopMode2 = UITrackingRunLoopMode;
    Boolean isObserver = CFRunLoopContainsObserver(runLoop, observer, runLoopMode1);
    if (isObserver == false) {
        NSLog(@"没观察");
        CFRunLoopAddObserver(runLoop, observer, runLoopMode1);
    }else{
        NSLog(@"已观察");
    }
    isObserver = CFRunLoopContainsObserver(runLoop, observer, runLoopMode2);
    if (isObserver == false) {
        CFRunLoopAddObserver(runLoop, observer, runLoopMode2);
    }
    
    
}
-(void)removeRunLoopObserver
{
    CFStringRef runLoopMode1 = kCFRunLoopDefaultMode;
    CFStringRef runLoopMode2 = UITrackingRunLoopMode;
    CFRunLoopRemoveObserver(runLoop, observer, runLoopMode1);
    CFRunLoopRemoveObserver(runLoop, observer, runLoopMode2);
    //CFRelease(observer); // 注意释放，否则会造成内存泄露
}
-(void)panAction:(UIPanGestureRecognizer *)panAction
{
    
}
- (void)prepareForReuse
{
    [super prepareForReuse];
    //[self resizeSubviewSize];
    [self removeRunLoopObserver];
}
- (void)resizeSubviewSize
{
    isDismiss = NO;
    [self observerRunLoop];
    _imageContainerView.transform = CGAffineTransformIdentity;
    _imageContainerView.origin = CGPointZero;
    _imageContainerView.width = SCREEN_WIDTH;//self.scrollView.width;
    
    CGFloat scrollViewHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat scrollViewWidth = SCREEN_WIDTH;
    UIImage *image = _photoImageView.image;
    
    
    if (image.size.height / image.size.width > scrollViewHeight / scrollViewWidth) {
        _imageContainerView.height = floor(image.size.height / (image.size.width / scrollViewWidth));
    } else {
        CGFloat height = image.size.height / image.size.width * scrollViewWidth;
        if (height < 1 || isnan(height)) height = scrollViewHeight;
        height = floor(height);
        _imageContainerView.height = height;
        _imageContainerView.centerY = scrollViewHeight / 2;
    }
    if (_imageContainerView.height > self.scrollView.height && _imageContainerView.height - self.scrollView.height <= 1) {
        _imageContainerView.height = self.scrollView.height;
    }
    //_imageContainerView.centerY = scrollViewHeight / 2;
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.width, MAX(_imageContainerView.height, self.scrollView.height));
    [self.scrollView scrollRectToVisible:self.scrollView.bounds animated:NO];
    
    if (_imageContainerView.height <= self.scrollView.height) {
        self.scrollView.alwaysBounceVertical = NO;
    } else {
        self.scrollView.alwaysBounceVertical = YES;
    }
    //
    //self.scrollView.alwaysBounceVertical = YES;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.photoImageView.frame = _imageContainerView.bounds;
    [CATransaction commit];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    //UIView *subView = _imageContainerView;
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    self.imageContainerView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)dismiss {
    [self removeRunLoopObserver];
    [self.browseView dismiss];
}

- (void)doubleTap:(UITapGestureRecognizer *)g {
    if (self.scrollView.zoomScale > 1) {
        [self.scrollView setZoomScale:1 animated:YES];
    } else {
        CGPoint touchPoint = [g locationInView:self.photoImageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.width / newZoomScale;
        CGFloat ysize = self.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }

}


- (void)pan:(UIPanGestureRecognizer *)g {
    switch (g.state) {
        case UIGestureRecognizerStateBegan: {
            _panGestureBeginPoint = [g locationInView:self];
        } break;
        case UIGestureRecognizerStateChanged: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            _scrollView.top = deltaY;
            
            CGFloat alphaDelta = 160;
            CGFloat alpha = (alphaDelta - fabs(deltaY) + 50) / alphaDelta;
            alpha = YY_CLAMP(alpha, 0, 1);
            [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
                //_blurBackground.alpha = alpha;
            } completion:nil];
            
        } break;
        case UIGestureRecognizerStateEnded: {
            if (_panGestureBeginPoint.x == 0 && _panGestureBeginPoint.y == 0) return;
            CGPoint v = [g velocityInView:self];
            CGPoint p = [g locationInView:self];
            CGFloat deltaY = p.y - _panGestureBeginPoint.y;
            
            if (fabs(v.y) > 1000 || fabs(deltaY) > 120) {

                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                
                BOOL moveToTop = (v.y < - 50 || (v.y < 50 && deltaY < 0));
                CGFloat vy = fabs(v.y);
                if (vy < 1) vy = 1;
                CGFloat duration = (moveToTop ? _scrollView.bottom : self.height - _scrollView.top) / vy;
                duration *= 0.8;
                duration = YY_CLAMP(duration, 0.05, 0.3);
                
                [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    //_blurBackground.alpha = 0;
                    if (moveToTop) {
                        _scrollView.bottom = 0;
                    } else {
                        _scrollView.top = self.height;
                    }
                } completion:^(BOOL finished) {
                    //[self removeFromSuperview];
                }];
                
                //_background.image = _snapshotImage;
                //[_background.layer addFadeAnimationWithDuration:0.3 curve:UIViewAnimationCurveEaseInOut];
                
            } else {
                [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:v.y / 1000 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
                    _scrollView.top = 0;
                    //_blurBackground.alpha = 1;
                } completion:^(BOOL finished) {
                    
                }];
            }
            
        } break;
        case UIGestureRecognizerStateCancelled : {
            _scrollView.top = 0;
            //_blurBackground.alpha = 1;
        }
        default:break;
    }
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if ([newSuperview isKindOfClass:[FKPhotoBrowseView class]]) {
        self.browseView = (FKPhotoBrowseView *)newSuperview;
    }
}
-(void)dealloc
{
    [self removeRunLoopObserver];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"意识");
}


@end
