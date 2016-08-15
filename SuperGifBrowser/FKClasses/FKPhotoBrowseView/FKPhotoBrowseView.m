//
//  FKPhotoBrowseView.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/30.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import "AppDelegate.h"
#import "FKPhotoBrowseView.h"
#import "FKPhotoBrowseCell.h"

#define SCREEN_WIDTH  [[UIScreen mainScreen] applicationFrame].size.width
#define SCREEN_HEIGHT  [UIScreen mainScreen].bounds.size.height
//[[UIScreen mainScreen] applicationFrame].size.height

NSString *dismissNotification = @"dismissNotification";

static NSString *FKPhotoCellIdentifier = @"FKPhotoBrowseCell";
@interface FKPhotoBrowseView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@end
@implementation FKPhotoBrowseView
- (instancetype)initWithFrame:(CGRect)frame
{
    
    CGFloat cellWidth = SCREEN_WIDTH + 20;
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.itemSize = CGSizeMake(cellWidth, SCREEN_HEIGHT);//每个cell的大小
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.delegate = self;
        self.dataSource = self;
        self.pagingEnabled = YES;
        [self registerNib:[UINib nibWithNibName:@"FKPhotoBrowseCell" bundle:nil] forCellWithReuseIdentifier:FKPhotoCellIdentifier];
        
        UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:beffect];
        
        //AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        
        effectView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        
        self.backgroundView = effectView;
    }
    
    return self;
}

#pragma mark collectionView delegate dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSAssert(self.fkDelegate, @"代理不能为空");
    if (self.fkDelegate && [self.fkDelegate respondsToSelector:@selector(numberOfItemsInFKPhotoBrowseView:)]) {
        return [self.fkDelegate numberOfItemsInFKPhotoBrowseView:self];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString *identifier = @"cell";
    FKPhotoBrowseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FKPhotoCellIdentifier forIndexPath:indexPath];
    UIImage *photoImage;
    if (self.fkDelegate && [self.fkDelegate respondsToSelector:@selector(collectionView:imageForItemAtIndex:)]) {
        photoImage = [self.fkDelegate collectionView:self imageForItemAtIndex:indexPath.row];
    }
    cell.photoImageView.image = photoImage;
    [cell resizeSubviewSize];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"选中了");
}

-(void)showFromIndex:(NSInteger)fromIndex
{
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    UIWindow *window = appDelegate.window;
    [window addSubview:self];
    [self reloadData];
    CGFloat width = self.frame.size.width;

    [self setContentOffset:CGPointMake(width*fromIndex, 0) animated:NO];
    //[self scrollRectToVisible:CGRectMake(width, 0, width, SCREEN_HEIGHT) animated:NO];
    self.alpha = 0;
    self.transform = CGAffineTransformMakeScale(0.5, 0.5);
    
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    } completion:nil];

}

-(void)dismiss
{
    [[NSNotificationCenter defaultCenter]postNotificationName:dismissNotification object:nil];
    self.fkDelegate = nil;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.alpha = 1;
    }];
    
}
@end
