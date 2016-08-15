//
//  FKAssetManager.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/28.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "FKAssetManager.h"

@implementation FKAssetManager
+(NSArray *)arrayPhotoData
{
    NSArray *photoGroups = [self arrayPhotoGroup];
    if (photoGroups.count) {
        return [[self loadAssets:photoGroups[0]]copy];
    }
    return nil;
}

+(NSArray *)arrayVideoAsset{
    NSArray *photoGroups = [self arrayPhotoGroup];
    NSLog(@"photoGroups:%d",photoGroups.count);
    if (photoGroups.count) {
        return [self loadVideoAssets:photoGroups[0]];
    }
    return nil;
}

/*
+(NSArray *)getPhotoGroup
{
    //创建一个信号量
    NSMutableArray *groups = [[NSMutableArray alloc]initWithCapacity:10];
    NSCondition *lock = [[NSCondition alloc]init];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
            NSLog(@"%d",[NSThread isMainThread]);
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                if (group.numberOfAssets > 0){
                    if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos){
                        NSLog(@"ALAssetsGroupSavedPhotos");
                        [groups insertObject:group atIndex:0];
                    } else if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupPhotoStream && groups.count > 0){
                        NSLog(@"ALAssetsGroupPhotoStream");
                        [groups insertObject:group atIndex:1];
                    } else {
                        NSLog(@"other");
                        [groups addObject:group];
                    }
                }
            } else {
                NSLog(@"dataReload");
                //[self loadAssets:groups[0]];
                [lock lock];
                [lock signal];
                [lock unlock];
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
            //没权限
            //[self showNotAllowed];
        };
        
        //显示的相册
        NSUInteger type = ALAssetsGroupSavedPhotos | ALAssetsGroupPhotoStream |
        ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent |
        ALAssetsGroupFaces  ;
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library enumerateGroupsWithTypes:type
                               usingBlock:resultsBlock
                             failureBlock:failureBlock];
        
    });
    [lock lock];
    [lock wait];
    [lock unlock];
    NSLog(@"----------：%d",groups.count);
    return groups;
}
*/

+(NSArray *)arrayPhotoGroup
{
    NSMutableArray *groups = [[NSMutableArray alloc]initWithCapacity:10];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ALAssetsLibraryGroupsEnumerationResultsBlock resultsBlock = ^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allAssets]];
                if (group.numberOfAssets > 0){
                    if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupSavedPhotos){
                        [groups insertObject:group atIndex:0];
                    } else if ([[group valueForProperty:ALAssetsGroupPropertyType] intValue] == ALAssetsGroupPhotoStream && groups.count > 0){
                        [groups insertObject:group atIndex:1];
                    } else {
                        [groups addObject:group];
                    }
                }
            } else {
                dispatch_semaphore_signal(semaphore);
                
            }
        };
        
        ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        };
        
        //显示的相册
        NSUInteger type = ALAssetsGroupSavedPhotos | ALAssetsGroupPhotoStream |
        ALAssetsGroupLibrary | ALAssetsGroupAlbum | ALAssetsGroupEvent |
        ALAssetsGroupFaces  ;
        
        ALAssetsLibrary *library = [self defaultAssetsLibrary];
        [library enumerateGroupsWithTypes:type
                               usingBlock:resultsBlock
                             failureBlock:failureBlock];
        
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return [groups copy];

    
}

static ALAssetsLibrary * _assetsLibrary;
+ (ALAssetsLibrary *)assetsLibrary {
    if (!_assetsLibrary) {
        static dispatch_once_t pred = 0;
        static ALAssetsLibrary *library = nil;
        dispatch_once(&pred, ^{
            library = [[ALAssetsLibrary alloc] init];
        });
        _assetsLibrary = library;
    }
    return _assetsLibrary;
}


+ (NSArray *)loadAssets:(ALAssetsGroup *)assetsGroup {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSMutableArray *assets = [[NSMutableArray alloc]initWithCapacity:20];
    NSMutableArray *tempList = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset) {
                [tempList addObject:asset];
            } else if (tempList.count > 0) {
                //排序
                NSArray *sortedList = [tempList sortedArrayUsingComparator:^NSComparisonResult(ALAsset *first, ALAsset *second) {
                    if ([first isKindOfClass:[UIImage class]]) {
                        return NSOrderedAscending;
                    }
                    id firstData = [first valueForProperty:ALAssetPropertyDate];
                    id secondData = [second valueForProperty:ALAssetPropertyDate];
                    return [secondData compare:firstData];//降序
                }];
                [assets addObjectsFromArray:sortedList];
                dispatch_semaphore_signal(semaphore);
            }
        };
        
        [assetsGroup enumerateAssetsUsingBlock:resultsBlock];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    //NSLog(@"------:%d",assets.count);
    return assets;
    
}

+ (NSArray *)loadVideoAssets:(ALAssetsGroup *)assetsGroup {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSMutableArray *assets = [[NSMutableArray alloc]initWithCapacity:20];
    NSMutableArray *tempList = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ALAssetsGroupEnumerationResultsBlock resultsBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset) {
                //NSLog(@"遍历数组中");
                //NSLog(@"%@",[asset valueForProperty:ALAssetPropertyType]);
                if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
                    [tempList addObject:asset];
                }
                
                //[self.assetPaths addObject:[result valueForProperty:ALAssetPropertyAssetURL]];
                
                
            } else if (tempList.count > 0) {
                //排序
                NSLog(@"排序中");
                NSArray *sortedList = [tempList sortedArrayUsingComparator:^NSComparisonResult(ALAsset *first, ALAsset *second) {
                    if ([first isKindOfClass:[UIImage class]]) {
                        return NSOrderedAscending;
                    }
                    id firstData = [first valueForProperty:ALAssetPropertyDate];
                    id secondData = [second valueForProperty:ALAssetPropertyDate];
                    return [secondData compare:firstData];//降序
                }];
                [assets addObjectsFromArray:sortedList];
                dispatch_semaphore_signal(semaphore);
            }else{
                dispatch_semaphore_signal(semaphore);
            }
        };
        
        [assetsGroup enumerateAssetsUsingBlock:resultsBlock];
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    //NSLog(@"------:%d",assets.count);
    return assets;
    
}

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}
@end
