//
//  FKVideoChooseController.m
//  SuperGifBrowser
//
//  Created by LiJingBiao on 16/4/13.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import "GifGenerator.h"
#import "FKVideoChooseCell.h"
#import "FKAssetManager.h"
#import "FKCollectionViewCell.h"
#import "FKCollectionView.h"
#import "FKMainController.h"
#import "Masonry.h"
#import "FKPhotoBrowseView.h"
#import "WKProgressHUD.h"
#import "FKFileManager.h"
#import "FKVideoChooseController.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSString *FKCollectionViewIdentifier = @"FKVideoChooseCell";
@interface FKVideoChooseController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIActionSheetDelegate>
@property(nonatomic,assign)BOOL isLoadData;
@property (strong, nonatomic) IBOutlet UIButton *leftButton;
@property (strong, nonatomic) IBOutlet UIButton *rightButton;
@property (nonatomic,strong)  FKCollectionView *collectionView;
@property (nonatomic, strong, nullable) UIRefreshControl *refreshControl;
@property (nonatomic, assign) BOOL isShowSelectedButton;
@property(nonatomic, strong) NSMutableArray *modelArray;



@property(nonatomic,assign) NSInteger selectedIndex;
@end

@implementation FKVideoChooseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:236.0/255.0 green:66.0/255.0 blue:67.0/255.0 alpha:1.0]];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:self.leftButton];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    //self.navigationItem.rightBarButtonItem = rightItem;
    
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
    [self.view bringSubviewToFront:self.collectionView];

}


#pragma mark 获取photo

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.isLoadData) {
        [self loadPhotoData];
    }
    self.collectionView.scrollEnabled = YES;

    
}
-(void)loadPhotoData
{
    if (self.modelArray.count) {
        [self.modelArray removeAllObjects];
    }
    NSArray *assetsArray = [FKAssetManager arrayVideoAsset];
    NSLog(@"------");
    NSLog(@"=======%d",assetsArray.count);
    [self.modelArray addObjectsFromArray:assetsArray];
    /*
    for (ALAsset *asset in assetsArray) {
        FKCollectionViewCellModel *model = [FKCollectionViewCellModel new];
        model.photoAsset = asset;
        [self.modelArray addObject:model];
    }
     */
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
   
}

#pragma mark collectionView delegate dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //return 25;
    return self.modelArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FKVideoChooseCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FKCollectionViewIdentifier forIndexPath:indexPath];
    //FKCollectionViewCellModel *model = self.modelArray[indexPath.row];
    //cell.fkCellModel = model;
    //cell.showSelectedButton = self.isShowSelectedButton;
    cell.asset = self.modelArray[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
 
    ALAsset *asset = self.modelArray[indexPath.row];
    NSURL *url = [asset valueForProperty:ALAssetPropertyAssetURL];
    NSLog(@"=====:%@",url);
    [WKProgressHUD showInView:self.view withText:@"正在生成GIF" animated:YES];
    [[GifGenerator shared]generatorGifWithVideoURL:url VideoToImagesGifBlock:^(NSString *VideoToImagesGifPath, NSError *error) {
        [WKProgressHUD dismissInView:self.view animated:YES];
        NSLog(@"VideoToImagesGifPath:%@",VideoToImagesGifPath);
    }];
    /*
    self.selectedIndex = indexPath.row;
    //FKCollectionViewCellModel *model = self.modelArray[indexPath.row];
    //self.saveImageURL = model.photoPath;
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享到微信", nil];
    //[sheet showInView:self.view];
    */
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


- (IBAction)deleteAction:(UIButton *)sender {
    [WKProgressHUD showInView:self.view.window withText:@"删除中..." animated:YES];
    for (FKCollectionViewCellModel *model in self.modelArray) {
        if (model.isSelectedButton) {
            NSString *photoPath = model.photoPath;
            [FKFileManager removeImageAtPath:photoPath];
            model.isSelectedButton = NO;
        }
    }
    [self.modelArray removeAllObjects];
    [self rightButtonAction:nil];
    [self loadPhotoData];
    [WKProgressHUD dismissInView:self.view.window animated:YES];
}

#pragma mark actionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%d",self.selectedIndex);
    FKCollectionViewCellModel *model = self.modelArray[self.selectedIndex];
    NSData *data = [NSData dataWithContentsOfFile:model.photoPath];
    if (buttonIndex == 0) {
        [FKShareManager shareImageWithData:data isWX:YES];
    }else if (buttonIndex == 1){
        [FKShareManager shareImageWithData:data isWX:YES];
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
    }
    NSLog(@"%d",buttonIndex);
}

@end
