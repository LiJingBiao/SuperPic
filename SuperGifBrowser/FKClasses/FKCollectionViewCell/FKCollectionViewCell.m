//
//  FKCollectionViewCell.m
//  SuperGifBrowser
//
//  Created by lijingbiao on 16/3/28.
//  Copyright © 2016年 LiJingBiao. All rights reserved.
//
#import <MobileCoreServices/UTCoreTypes.h>
#import "FKCollectionViewCell.h"
@interface FKCollectionViewCell()


@property (weak, nonatomic) IBOutlet UIButton *selectedButton;

@end
@implementation FKCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    YYImage *image = [YYImage imageNamed:@"example"];
    _photoImageView.image = image;

}
- (IBAction)selectedButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.fkCellModel.isSelectedButton = sender.selected;
}
-(void)setButtonSelelcted
{
    _selectedButton.selected = !_selectedButton.selected;
    self.fkCellModel.isSelectedButton = _selectedButton.selected;
}
-(void)setShowSelectedButton:(BOOL)showSelectedButton
{
    _showSelectedButton = showSelectedButton;
    self.selectedButton.hidden = !showSelectedButton;
}
-(void)setFkCellModel:(FKCollectionViewCellModel *)fkCellModel
{
    if (_fkCellModel != fkCellModel) {
        _fkCellModel = fkCellModel;
         UIImage *photoImage;
        if (fkCellModel.photoAsset) {
            ALAsset *asset = fkCellModel.photoAsset;
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
        }
        else if (fkCellModel.photoPath.length){
            photoImage = [YYImage imageWithContentsOfFile:fkCellModel.photoPath];
            //NSLog(@"%d",fkCellModel.photoPath);
        }
        self.selectedButton.selected = fkCellModel.isSelectedButton;
        self.photoImageView.image = photoImage;
    }
}

@end
@implementation FKCollectionViewCellModel

@end