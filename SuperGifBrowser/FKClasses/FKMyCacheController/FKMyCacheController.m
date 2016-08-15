//
//  FKMyCacheController.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/4/5.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//

#import "FKCollectionViewCell.h"
#import "FKCollectionView.h"
#import "FKMainController.h"
#import "Masonry.h"
#import "FKPhotoBrowseView.h"
#import "WKProgressHUD.h"
#import "FKFileManager.h"
#import "FKMyCacheController.h"
#import "WXApi.h"
#import "WXApiObject.h"
static NSString *FKCollectionViewIdentifier = @"FKCollectionViewCell";
@interface FKMyCacheController ()<UICollectionViewDelegate,UICollectionViewDataSource,FKPhotoBrowseViewDelegate,UIActionSheetDelegate>
@property(nonatomic,assign)BOOL isLoadData;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;
@property (nonatomic,strong)  FKCollectionView *collectionView;
@property (nonatomic, strong, nullable) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL isShowSelectedButton;
@property(nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong)FKPhotoBrowseView *photoBrowseView;
@property(nonatomic,copy) NSString *saveImageURL;

@property (strong, nonatomic) IBOutlet UIButton *backButton;

@property (weak, nonatomic)   IBOutlet UIToolbar *toolBar;

@property (strong, nonatomic) NSIndexPath *lastAccessed;
@property (strong, nonatomic)UIPanGestureRecognizer *pan;
@end

@implementation FKMyCacheController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:236.0/255.0 green:66.0/255.0 blue:67.0/255.0 alpha:1.0]];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:self.leftButton];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    __weak typeof(self) weakSelf = self;
    self.collectionView = [[FKCollectionView alloc]initWithFrame:CGRectZero];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerNib:[UINib nibWithNibName:FKCollectionViewIdentifier bundle:nil] forCellWithReuseIdentifier:FKCollectionViewIdentifier];
    self.collectionView.alwaysBounceVertical = YES;
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(weakSelf.view);
    }];
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    self.refreshControl.tintColor = [UIColor colorWithRed:236.0/255.0 green:66.0/255.0 blue:67.0/255.0 alpha:1.0];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新了~~"];
    [self.refreshControl addTarget:self action:@selector(refreshChange:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    
    self.modelArray = [[NSMutableArray alloc]initWithCapacity:20];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.backButton];
    
     self.toolBar.hidden = YES;
    [self.view bringSubviewToFront:self.toolBar];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(onPanForSelection:)];
    [self.view addGestureRecognizer:pan];
    self.pan = pan;
    pan.enabled = NO;
}


#pragma mark - Action
- (void)onPanForSelection:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:_collectionView];
    
    for (FKCollectionViewCell *cell in _collectionView.visibleCells) {
        if (CGRectContainsPoint(cell.frame, point)) {
            NSIndexPath *indexPath = [_collectionView indexPathForCell:cell];
            if (_lastAccessed != indexPath) {
                //[self collectionView:_collectionView didSelectItemAtIndexPath:indexPath];
                [cell setButtonSelelcted];
            }
            _lastAccessed = indexPath;
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        _lastAccessed = nil;
    }
}

- (IBAction)backAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)rightButtonAction:(UIButton *)sender {
    self.toolBar.hidden = !self.toolBar.hidden;
    if (self.toolBar.hidden) {
        [_rightButton setTitle:@"多选" forState:UIControlStateNormal];
        self.isShowSelectedButton = NO;
        self.pan.enabled = NO;
    }else{
        [_rightButton setTitle:@"取消多选" forState:UIControlStateNormal];
        self.isShowSelectedButton = YES;
        self.pan.enabled = YES;
        for (FKCollectionViewCellModel *model in self.modelArray) {
            model.isSelectedButton = NO;
        }
    }
    [self.collectionView reloadData];

}


#pragma mark 获取photo

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.isLoadData) {
        [self loadPhotoData];
    }
    
    
}
-(void)loadPhotoData
{
    if (self.modelArray.count) {
        [self.modelArray removeAllObjects];
    }
    NSArray *imagePathArray = [FKFileManager imagePathInMyWebCachePath];
    if (self.isFromMyCache) {
        imagePathArray = [FKFileManager imagePathInMyWebCachePath];
    }else{
        imagePathArray = [FKFileManager imagePathFromDirectory];
    }
    for (NSString *imagePath in imagePathArray) {
        FKCollectionViewCellModel *model = [FKCollectionViewCellModel new];
        model.photoPath = imagePath;
        [self.modelArray addObject:model];
    }
    [self.collectionView reloadData];
    self.isLoadData = YES;
    [self.refreshControl endRefreshing];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"下拉刷新了~~"];
    
}
#pragma mark 刷新
-(void)refreshChange:(UIRefreshControl*)refreshControl{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc]initWithString:@"开始刷新了~~"];
    [self loadPhotoData];
}


#pragma mark collectionView delegate dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.modelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FKCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FKCollectionViewIdentifier forIndexPath:indexPath];
    FKCollectionViewCellModel *model = self.modelArray[indexPath.row];
    cell.fkCellModel = model;
    cell.showSelectedButton = self.isShowSelectedButton;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FKCollectionViewCellModel *model = self.modelArray[indexPath.row];
    self.saveImageURL = model.photoPath;
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加到我的收藏",@"分享到微信",@"分享到QQ",@"删除照片", nil];
    [sheet showInView:self.view];
    NSLog(@"点击了");
    NSLog(@"%@",model.photoPath);
    
}

#pragma mark FKPhotoBrowseViewDelegate
- (NSInteger)numberOfItemsInFKPhotoBrowseView:(FKPhotoBrowseView *)collectionView
{
    return self.modelArray.count;
}

- (UIImage *)collectionView:(UICollectionView *)collectionView imageForItemAtIndex:(NSInteger)index
{
    return [self imageFromIndex:index];
}

#pragma mark utile
-(UIImage *)imageFromIndex:(NSInteger)index
{
    if (self.modelArray.count>index) {
        FKCollectionViewCellModel *model = self.modelArray[index];
        YYImage *image = [YYImage imageWithContentsOfFile:model.photoPath];
        return image;
    }
    return nil;
}



#pragma mark actionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
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
    }else if (buttonIndex == 1){
        [FKShareManager shareImageWithData:[NSData dataWithContentsOfFile:self.saveImageURL] isWX:YES];
    }else if (buttonIndex == 2){
        [FKShareManager shareImageWithData:[NSData dataWithContentsOfFile:self.saveImageURL] isWX:NO];
    }else if (buttonIndex == 3){//删除照片
        [FKFileManager removeImageAtPath:self.saveImageURL];
        [self loadPhotoData];
    }
    NSLog(@"%d",buttonIndex);
}

- (IBAction)deleteButtonAction:(UIButton *)sender {
    [WKProgressHUD showInView:self.view.window withText:@"删除中..." animated:YES];
    for (FKCollectionViewCellModel *model in self.modelArray) {
        if (model.isSelectedButton) {
            NSString *photoPath = model.photoPath;
            [FKFileManager removeImageAtPath:photoPath];
            model.isSelectedButton = NO;
        }
    }
    [self.modelArray removeAllObjects];
    //[self rightButtonAction:nil];
    [self loadPhotoData];
    [WKProgressHUD dismissInView:self.view.window animated:YES];

}
- (IBAction)likeAction:(UIButton *)sender {
    [WKProgressHUD showInView:self.view.window withText:@"保存中..." animated:YES];
    
#define BACK(block) dispatch_async(dispatch_get_global_queue(0, 0), block)
#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)
    
    BACK(^{
        for (FKCollectionViewCellModel *model in self.modelArray) {
            if (model.isSelectedButton) {
                NSString *photoPath = model.photoPath;
                [FKFileManager copyItemPathToMyGifPathFromPath:photoPath];
                //[FKFileManager removeImageAtPath:photoPath];
                model.isSelectedButton = NO;
            }
        }
        MAIN(^{
            [self loadPhotoData];
            [WKProgressHUD dismissInView:self.view.window animated:YES];
            [_rightButton setTitle:@"多选" forState:UIControlStateNormal];
            self.isShowSelectedButton = NO;
            self.pan.enabled = NO;
            self.toolBar.hidden = YES;
        });
    });
    
    
}

@end
