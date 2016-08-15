//
//  LocalViewController.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/25.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import "LocalPhotoCollectionViewCell.h"
#import "LocalViewController.h"
#import "PhotoBroswerVC.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "AJPhotoListCell.h"
#import "Masonry.h"
#import "UIViewController+MMDrawerController.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
@interface LocalViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,PhotoBroswerVCdelegate>
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UIView *navBar;
@property (weak, nonatomic) UIView *bgMaskView;
@property (weak, nonatomic) UIImageView *selectTip;
@property (weak, nonatomic) UIButton *okBtn;
@property (strong, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic) NSIndexPath *lastAccessed;
@property(nonatomic,assign) NSUInteger selectedIndex;
@property(nonatomic,strong)PhotoBroswerVC *photoVC;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic ,strong) NSMutableArray *paths;
@end

@implementation LocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _paths = [[NSMutableArray alloc]initWithCapacity:10];
    //导航条
    [self setupNavBar];
    [self.collectionView registerClass:[LocalPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"identifier"];
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadLocalPhotoPath];
}


-(void)loadLocalPhotoPath
{
    [_paths removeAllObjects];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSLog(@"documentsDirectory%@",documentsDirectory);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *gifDirectory = [documentsDirectory stringByAppendingPathComponent:@"GIF"];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:gifDirectory isDirectory:&isDir]) {
        // 创建目录
        [fileManager createDirectoryAtPath:gifDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        NSLog(@"不存在");
    }else{
        NSLog(@"存在");
    }
    NSArray *files = [fileManager subpathsOfDirectoryAtPath: gifDirectory error:nil];

    if (files.count) {
        for (NSString *path in files) {
            if (![path isEqualToString:@".DS_Store"]) {
                NSString *photoPath = [gifDirectory stringByAppendingPathComponent:path];
                [_paths addObject:photoPath];
            }
        }
    }
    [self.collectionView reloadData];
    NSLog(@"%@",_paths);

}

/**
 *  头部导航
 */
- (void)setupNavBar {
    //界面组件
    UIView *navBar = [[UIView alloc] init];
    navBar.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:66.0/255.0 blue:67.0/255.0 alpha:1.0];
    [self.view addSubview:navBar];
    [navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@64);
        make.leading.mas_equalTo(self.view);
        make.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
    }];
    self.navBar = navBar;
    
    //cancelBtn
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"左菜单" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@44);
        make.leading.mas_equalTo(navBar);
        make.top.mas_equalTo(navBar).offset(20);
        make.width.mas_equalTo(@60);
    }];
    
    //okBtn
    UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [okBtn setTitle:@"刷新" forState:UIControlStateNormal];
    [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [okBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [okBtn addTarget:self action:@selector(okBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:okBtn];
    [okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@44);
        make.trailing.mas_equalTo(navBar);
        make.top.mas_equalTo(navBar).offset(20);
        make.width.mas_equalTo(@60);
    }];
    self.okBtn = okBtn;
}
- (void)cancelBtnAction:(UIButton *)sender {
    
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    
}

- (void)okBtnAction:(UIButton *)sender {
    [self loadLocalPhotoPath];
}

#pragma mark - uicollectionDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.paths.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifer = @"identifier";
    LocalPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifer forIndexPath:indexPath];
    YYImage *image = [YYImage imageWithContentsOfFile:self.paths[indexPath.row]];
    [cell setPhotoImage:image];
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat wh = (collectionView.bounds.size.width - 20)/3.0;
    return CGSizeMake(wh, wh);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    PhotoBroswerVC *photoVC = [[PhotoBroswerVC alloc]initShow:self index:indexPath.row pageCount:self.paths.count];
    photoVC.delegate = self;
    [photoVC show];
    return;

}

#pragma mark PhotoBroswerVCdelegate
-(NSUInteger)totalShowImageCount
{
    return self.paths.count;
}

-(int)fromeIndex
{
    return self.selectedIndex;
}

-(PhotoModel *)getPhotoModelFromIndex:(NSUInteger)index
{
    PhotoModel *pbModel=[[PhotoModel alloc] init];
    pbModel.mid = index + 1;
     YYImage *image = [YYImage imageWithContentsOfFile:self.paths[index]];
    AJPhotoListCell *cell = (AJPhotoListCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
    pbModel.image = image;
    pbModel.sourceImageView = cell.imageView;
    if (self.selectedIndex == index) {
        pbModel.isFromSourceFrame = YES;
    }
    return pbModel;
}
@end
