//
//  HDSLandscapeLayout.m
//  CCLiveCloud
//
//  Created by Richard Lee on 8/30/21.
//  Copyright © 2021 MacBook Pro. All rights reserved.
//

#import "HDSLandscapeLayout.h"

@interface HDSLandscapeLayout ()<UICollectionViewDelegateFlowLayout>

@end

@implementation HDSLandscapeLayout

- (void)prepareLayout {
    [super prepareLayout];
    //设置滚动方向为横向滚动
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    //设置单元格的大小
    self.itemSize = CGSizeMake(124.5, 70);
    //设置item间距
    self.minimumInteritemSpacing = 5;
    self.minimumLineSpacing = 5;
    //设置左右间距 在collectionView初始位置 和 最后位置保证在也停留在正中间
    self.sectionInset = UIEdgeInsetsMake(5,0,5,0);
}

//开启实时刷新布局
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(124.5, 70);
}

@end
