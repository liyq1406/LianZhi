//
//  MyGiftVC.m
//  LianZhiParent
//
//  Created by jslsxu on 15/11/24.
//  Copyright © 2015年 jslsxu. All rights reserved.
//

#import "MyGiftVC.h"

@implementation GiftItem

- (void)parseData:(TNDataWrapper *)dataWrapper
{
    self.giftID = [dataWrapper getStringForKey:@"id"];
    self.giftName = [dataWrapper getStringForKey:@"name"];
    self.coin = [dataWrapper getIntegerForKey:@"coin"];
    self.url = [dataWrapper getStringForKey:@"url"];
    self.width = [dataWrapper getFloatForKey:@"width"];
    self.height = [dataWrapper getFloatForKey:@"height"];
    self.ctype = [dataWrapper getIntegerForKey:@"ctype"];
}

@end

@implementation GiftModel
- (BOOL)hasMoreData
{
    return NO;
}
- (BOOL)parseData:(TNDataWrapper *)data type:(REQUEST_TYPE)type
{
    if(type == REQUEST_REFRESH)
        [self.modelItemArray removeAllObjects];
    TNDataWrapper *userCoinWrapper = [data getDataWrapperForKey:@"user_coin"];
    self.coinTotal = [userCoinWrapper getIntegerForKey:@"coin_total"];
    TNDataWrapper *presentWrapper = [data getDataWrapperForKey:@"persents"];
    for (NSInteger i = 0; i < presentWrapper.count; i++)
    {
        TNDataWrapper *presentItemWrapper = [presentWrapper getDataWrapperForIndex:i];
        GiftItem *item = [[GiftItem alloc] init];
        [item parseData:presentItemWrapper];
        if(item.coin > 0)
            [item setNum:self.coinTotal / item.coin];
        [self.modelItemArray addObject:item];
    }
    return YES;
}

@end

@implementation GiftCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.width)];
        [_imageView.layer setCornerRadius:8];
        [_imageView.layer setBorderWidth:0.5];
        [_imageView.layer setMasksToBounds:YES];
        [_imageView.layer setBorderColor:[UIColor colorWithHexString:@"d8d8d8"].CGColor];
        [self addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _imageView.bottom, _imageView.width, 20)];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setFont:[UIFont systemFontOfSize:13]];
        [_titleLabel setTextColor:[UIColor colorWithHexString:@"2c2c2c"]];
        [self addSubview:_titleLabel];
        
        _coinLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _titleLabel.bottom, _imageView.width, 20)];
        [_coinLabel.layer setCornerRadius:10];
        [_coinLabel.layer setMasksToBounds:YES];
        [_coinLabel setTextColor:[UIColor whiteColor]];
        [_coinLabel setFont:[UIFont systemFontOfSize:13]];
        [_coinLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_coinLabel];
    }
    return self;
}

- (void)onReloadData:(TNModelItem *)modelItem
{
    GiftItem *giftItem = (GiftItem *)modelItem;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:giftItem.url] placeholderImage:nil];
    [_titleLabel setText:giftItem.giftName];
    [_coinLabel setText:[NSString stringWithFormat:@"%ld个连枝币",giftItem.coin]];
    if(giftItem.num > 0)
        [_coinLabel setBackgroundColor:[UIColor colorWithHexString:@"F4A116"]];
    else
    {
        [_coinLabel setBackgroundColor:[UIColor colorWithHexString:@"cccccc"]];
    }
}

@end

@implementation MyGiftVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.cellName = @"GiftCell";
        self.modelName = @"GiftModel";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = @"礼物";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onCancel)];
    self.supportPullDown = YES;
    self.supportPullUp = YES;
    [self requestData:REQUEST_REFRESH];
}

- (HttpRequestTask *)makeRequestTaskWithType:(REQUEST_TYPE)requestType
{
    HttpRequestTask *task = [[HttpRequestTask alloc] init];
    [task setRequestUrl:@"user/persent"];
    [task setRequestMethod:REQUEST_GET];
    [task setRequestType:requestType];
    [task setObserver:self];
    return task;
}

- (void)TNBaseCollectionViewControllerModifyLayout:(UICollectionViewLayout *)layout
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)layout;
    [flowLayout setSectionInset:UIEdgeInsetsMake(15, 15, 15, 15)];
    NSInteger itemSize = (self.view.width - 15 * 2 - 10 * 2) / 3;
    [flowLayout setItemSize:CGSizeMake(itemSize, itemSize + 20 + 20)];
    [flowLayout setMinimumLineSpacing:10];
    
}

- (void)onCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)TNBaseTableViewControllerItemSelected:(TNModelItem *)modelItem atIndex:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if(self.completion)
        self.completion(nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
