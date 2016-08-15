//
//  FKMainController.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/28.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FKCollectionView.h"
#import "FKCollectionViewCell.h"
#import "FKMainController.h"
#import "Masonry.h"
#import "FKAssetManager.h"
#import "FKPhotoBrowseView.h"
#import <objc/runtime.h>
#import "WKProgressHUD.h"
#import "FKFileManager.h"

#import "WXApi.h"
#import "WXApiObject.h"
static NSString *FKCollectionViewIdentifier = @"FKCollectionViewCell";

@interface FKMainController ()<UICollectionViewDelegate,UICollectionViewDataSource,FKPhotoBrowseViewDelegate,UIActionSheetDelegate>
@property(nonatomic,assign)BOOL isLoadData;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic)   IBOutlet UIToolbar *toolBar;
@property (nonatomic,strong)  FKCollectionView *collectionView;
@property (nonatomic, strong, nullable) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL isShowSelectedButton;
@property(nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong)FKPhotoBrowseView *photoBrowseView;
@property(nonatomic,assign) NSInteger selectedIndex;
@end

@implementation FKMainController

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
    [self.view bringSubviewToFront:self.toolBar];
    self.toolBar.hidden = YES;

}
- (void)pan:(UIPanGestureRecognizer *)g{
    NSLog(@"g");
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
    NSArray *assetsArray = [FKAssetManager arrayPhotoData];
    for (ALAsset *asset in assetsArray) {
        FKCollectionViewCellModel *model = [FKCollectionViewCellModel new];
        model.photoAsset = asset;
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
#pragma mark 左按钮点击事件
- (IBAction)leftButtonAction:(UIButton *)sender {
    NSLog(@"点击");
}
- (IBAction)rightButtonAction:(UIButton *)sender {
    self.toolBar.hidden = !self.toolBar.hidden;
    if (self.toolBar.hidden) {
        [_rightButton setTitle:@"多选" forState:UIControlStateNormal];
        self.isShowSelectedButton = NO;
    }else{
        [_rightButton setTitle:@"取消多选" forState:UIControlStateNormal];
        self.isShowSelectedButton = YES;
    }
    [self.collectionView reloadData];
}

#pragma mark collectionView delegate dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.modelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FKCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FKCollectionViewIdentifier forIndexPath:indexPath];
    FKCollectionViewCellModel *cellModel = self.modelArray[indexPath.row];
    //cell.photoImageView.image = [self imageFromIndex:indexPath.row];
    cell.fkCellModel = cellModel;
    cell.showSelectedButton = self.isShowSelectedButton;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.row;
    //FKCollectionViewCellModel *model = self.modelArray[indexPath.row];
    //self.saveImageURL = model.photoPath;
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加到我的收藏",@"分享到微信",@"分享到QQ", nil];
    [sheet showInView:self.view];
    /*
    CGFloat screeeWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screeeHeight = [UIScreen mainScreen].bounds.size.height;
    if (!self.photoBrowseView) {
        self.photoBrowseView = [[FKPhotoBrowseView alloc]initWithFrame:CGRectMake(-10, 0, screeeWidth+20, screeeHeight)];
    }
    self.photoBrowseView.fkDelegate = self;
    [self.photoBrowseView showFromIndex:indexPath.row];
    */
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
        ALAsset *asset = model.photoAsset;
        UIImage *photoImage;
        ALAssetRepresentation *re = [asset defaultRepresentation];
        if ([re.UTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
            long long size = re.size;
            uint8_t *buffer = malloc(size);
            NSError *error;
            NSUInteger bytes = [re getBytes:buffer fromOffset:0 length:size error:&error];
            NSData *data = [NSData dataWithBytes:buffer length:bytes];
            free(buffer);
            photoImage = [YYImage imageWithData:data];
        }else{
            photoImage = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
        }
        return photoImage;
    }
    return nil;
}

- (IBAction)shareAction:(UIButton *)sender {
}

- (IBAction)collectionAction:(UIButton *)sender {
    [WKProgressHUD showInView:self.view.window withText:@"保存中..." animated:YES];
    NSString *myGifDir = [FKFileManager myGifPath];
    for (FKCollectionViewCellModel *model in self.modelArray) {
        if (model.isSelectedButton) {
            ALAsset *asset = model.photoAsset;
            ALAssetRepresentation *re = [asset defaultRepresentation];
            NSString *fileName = re.filename;
            long long size = re.size;
            uint8_t *buffer = malloc(size);
            NSError *error;
            NSUInteger bytes = [re getBytes:buffer fromOffset:0 length:size error:&error];
            NSData *data = [NSData dataWithBytes:buffer length:bytes];
            free(buffer);
            //photoImage = [YYImage imageWithData:data];
            NSString *writePath = [myGifDir stringByAppendingPathComponent:fileName];
            [data writeToFile:writePath atomically:YES];
            model.isSelectedButton = NO;
        }
        
    }
    [self rightButtonAction:nil];
    [WKProgressHUD dismissInView:self.view.window animated:YES];
}

#pragma mark actionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%d",self.selectedIndex);
    FKCollectionViewCellModel *model = self.modelArray[self.selectedIndex];
    ALAsset *asset = model.photoAsset;
    //UIImage *photoImage;
    //NSData *photodata;
    ALAssetRepresentation *re = [asset defaultRepresentation];
    long long size = re.size;
    uint8_t *buffer = malloc(size);
    NSError *error;
    NSUInteger bytes = [re getBytes:buffer fromOffset:0 length:size error:&error];
    NSData *data = [NSData dataWithBytes:buffer length:bytes];
    free(buffer);
    NSString *imageName = re.filename;
    if (buttonIndex == 0) {
        [FKFileManager myGifPathWriteImageData:data withName:imageName];
    }else if (buttonIndex == 1){
        [FKShareManager shareImageWithData:data  isWX:YES];
//        WXMediaMessage *message = [WXMediaMessage message];
//        //[message setThumbImage:[UIImage imageWithData:photodata]];
//        [message setThumbData:data];
//        WXEmoticonObject *ext = [WXEmoticonObject object];
//        ext.emoticonData = data;
//        message.mediaObject = ext;
//        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
//        req.bText = NO;
//        req.message = message;
//        req.scene = WXSceneSession;
//        [WXApi sendReq:req];
    }else if (buttonIndex == 2){
        [FKShareManager shareImageWithData:data  isWX:NO];
    }
    NSLog(@"%d",buttonIndex);
}

@end
