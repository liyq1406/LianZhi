//
//  PhotoFlowCell.m
//  LianZhiParent
//
//  Created by jslsxu on 14/12/22.
//  Copyright (c) 2014年 jslsxu. All rights reserved.
//

#import "PhotoFlowCell.h"

@implementation PhotoFlowCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setClipsToBounds:YES];
        [self setBackgroundColor:[UIColor lightGrayColor]];
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [_imageView setClipsToBounds:YES];
        [self addSubview:_imageView];
    }
    return self;
}

- (void)onReloadData:(TNModelItem *)modelItem
{
    PhotoItem *item = (PhotoItem *)modelItem;
    if(item.photoID.length && item.thumbnailUrl.length > 0)
    {
        [self setBackgroundColor:[UIColor lightGrayColor]];
        [_imageView setFrame:self.bounds];
        [_imageView sd_setImageWithURL:[NSURL URLWithString:item.thumbnailUrl] placeholderImage:nil];
    }
    else
    {
        [self setBackgroundColor:kCommonTeacherTintColor];
        [_imageView setFrame:CGRectInset(self.bounds, 30, 30)];
        [_imageView setImage:[UIImage imageNamed:(@"PhotoFromAlbum.png")]];
    }
}
@end
