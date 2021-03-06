//
//  ApplicationBoxVC.m
//  LianZhiTeacher
//
//  Created by jslsxu on 15/8/12.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import "ApplicationBoxVC.h"
#import "NotificationToAllVC.h"
#import "PublishGrowthTimelineVC.h"
#import "ContactListVC.h"
#import "ClassSelectionVC.h"
#import "GrowthTimelineVC.h"
#import "PhotoFlowVC.h"
#import "HomeWorkVC.h"
#import "ClassAttendanceVC.h"
#import "MyAttendanceVC.h"
#import "LZAccountVC.h"
@implementation ApplicationItem

- (void)parseData:(TNDataWrapper *)dataWrapper
{
    self.icon = [dataWrapper getStringForKey:@"icon"];
    self.appId = [dataWrapper getStringForKey:@"id"];
    self.name = [dataWrapper getStringForKey:@"name"];
    self.url = [dataWrapper getStringForKey:@"url"];
}
@end

@implementation ApplicationItemCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self.layer setCornerRadius:10];
        [self.layer setMasksToBounds:YES];
        [self setBackgroundColor:[UIColor colorWithHexString:@"dbdbdb"]];
        _appImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - 56) / 2, 8, 56, 56)];
        [_appImageView setClipsToBounds:YES];
        [_appImageView  setContentMode:UIViewContentModeScaleAspectFill];
        [self addSubview:_appImageView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _appImageView.bottom, self.width, 15)];
        [_nameLabel setTextColor:[UIColor colorWithHexString:@"2c2c2c"]];
        [_nameLabel setFont:[UIFont systemFontOfSize:12]];
        [_nameLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_nameLabel];
        
        _indicator = [[NumIndicator alloc] initWithFrame:CGRectZero];
        [self addSubview:_indicator];
        
        NSInteger height = _appImageView.height + 15 + 6;
        [_appImageView setY:(self.height - height) / 2];
        [_nameLabel setY:_appImageView.bottom + 6];

    }
    return self;
}

- (void)onReloadData:(TNModelItem *)modelItem
{
    ApplicationItem *item = (ApplicationItem *)modelItem;
    [_appImageView sd_setImageWithURL:[NSURL URLWithString:item.icon] placeholderImage:nil];
    [_nameLabel setText:item.name];
    [self setBadge:item.badge];
}


- (void)setBadge:(NSString *)badge
{
    _badge = badge;
    [_indicator setOrigin:CGPointMake(_appImageView.right, _appImageView.y)];
    [_indicator setHidden:!_badge];
    [_indicator setIndicator:_badge];
}
@end

@implementation ApplicationModel

- (BOOL)parseData:(TNDataWrapper *)data type:(REQUEST_TYPE)type
{
    if(type == REQUEST_REFRESH)
        [self.modelItemArray removeAllObjects];
    TNDataWrapper *dataWrapper = [data getDataWrapperForKey:@"list"];
    if(dataWrapper.count > 0)
    {
        for (NSInteger i = 0; i < dataWrapper.count; i++)
        {
            TNDataWrapper *itemWrapper = [dataWrapper getDataWrapperForIndex:i];
            ApplicationItem *item = [[ApplicationItem alloc] init];
            [item parseData:itemWrapper];
            [self.modelItemArray addObject:item];
        }
    }
    return YES;
}

@end

@interface ApplicationBoxVC ()
@property (nonatomic, strong)NSMutableArray *appItems;
@property (nonatomic, copy)NSString *classBadge;
@end

@implementation ApplicationBoxVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        [self setCellName:@"ApplicationItemCell"];
        [self setModelName:@"ApplicationModel"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"ebebeb"]];
    [self requestData:REQUEST_REFRESH];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSchoolChanged) name:kUserCenterChangedSchoolNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStatusChanged) name:kStatusChangedNotification object:nil];
}

- (void)TNBaseCollectionViewControllerModifyLayout:(UICollectionViewLayout *)layout
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)layout;
    [flowLayout setSectionInset:UIEdgeInsetsMake(15, 15, 15, 15)];
    NSInteger itemSize = (self.view.width - 15 * 2 - 10 * 2) / 3;
    [flowLayout setItemSize:CGSizeMake(itemSize, itemSize)];
    [flowLayout setMinimumLineSpacing:10];
}

- (HttpRequestTask *)makeRequestTaskWithType:(REQUEST_TYPE)requestType
{
    HttpRequestTask *task = [[HttpRequestTask alloc] init];
    [task setRequestUrl:@"app/list"];
    [task setRequestMethod:REQUEST_GET];
    [task setRequestType:requestType];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:[UserCenter sharedInstance].curSchool.schoolID forKey:@"school_id"];
    [task setParams:params];
    [task setObserver:self];
    return task;
}

- (BOOL)supportCache
{
    return YES;
}

- (NSString *)cacheFileName
{
    return [NSString stringWithFormat:@"%@_%@",[self class],[UserCenter sharedInstance].curSchool.schoolID];
}

- (void)onSchoolChanged
{
    [self requestData:REQUEST_REFRESH];
}

- (void)onStatusChanged
{
    //新动态
    NSArray *newCommentArray = [UserCenter sharedInstance].statusManager.classNewCommentArray;
    NSInteger commentNum = 0;
    for (ClassInfo *classInfo in [UserCenter sharedInstance].curSchool.classes)
    {
        for (TimelineCommentItem *commentItem in newCommentArray)
        {
            if([commentItem.classID isEqualToString:classInfo.classID] && commentItem.alertInfo.num > 0)
                commentNum += commentItem.alertInfo.num;
        }
    }
    if(commentNum > 0)
        self.classBadge = kStringFromValue(commentNum);
    else
    {
        //新日志
        NSArray *newFeedArray = [UserCenter sharedInstance].statusManager.feedClassesNew;
        NSInteger num = 0;
        for (ClassFeedNotice *noticeItem in newFeedArray)
        {
            if([noticeItem.schoolID isEqualToString:[UserCenter sharedInstance].curSchool.schoolID])
            {
                num += noticeItem.num;
            }
        }
        if(num > 0)
            self.classBadge = @"";
        else
            self.classBadge = nil;
    }
    for (ApplicationItem *appItem in self.collectionViewModel.modelItemArray)
    {
        NSURL *url = [NSURL URLWithString:appItem.url];
        if([url.host isEqualToString:@"class"])
        {
            [appItem setBadge:self.classBadge];
        }
        if([url.host isEqualToString:@"leave"])
        {
            NSString *badge = [UserCenter sharedInstance].statusManager.leaveNum > 0 ? @"" : nil;
            [appItem setBadge:badge];
        }
    }
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView

- (void)TNBaseTableViewControllerRequestSuccess
{
    for (ApplicationItem *appItem in self.collectionViewModel.modelItemArray)
    {
        NSURL *url = [NSURL URLWithString:appItem.url];
        if([url.host isEqualToString:@"class"])
        {
            [appItem setBadge:self.classBadge];
        }
        if([url.host isEqualToString:@"leave"])
        {
            NSString *badge = [UserCenter sharedInstance].statusManager.leaveNum > 0 ? @"" : nil;
            [appItem setBadge:badge];
        }
    }

}

- (void)TNBaseTableViewControllerItemSelected:(TNModelItem *)modelItem atIndex:(NSIndexPath *)indexPath
{
    ApplicationItem *item = (ApplicationItem *)modelItem;
    NSString *url = item.url;
    if([url hasPrefix:@"http"])
    {
        TNBaseWebViewController *webVC = [[TNBaseWebViewController alloc] init];
        [webVC setUrl:url];
        [CurrentROOTNavigationVC pushViewController:webVC animated:YES];
    }
    else if([url hasPrefix:@"lianzhi://"])
    {
        NSURL *path = [NSURL URLWithString:url];
        NSString *host = path.host;
        if([host isEqualToString:@"notice"])//发通知
        {
            [CurrentROOTNavigationVC pushViewController:[NotificationToAllVC sharedInstance] animated:YES];
        }
        else if([host isEqualToString:@"contact"])//联系人
        {
            ContactListVC *contactListVC = [[ContactListVC alloc] init];
            [CurrentROOTNavigationVC pushViewController:contactListVC animated:YES];
        }
        else if([host isEqualToString:@"class"])//班博客
        {
            NSMutableDictionary *classInfoDic = [NSMutableDictionary dictionary];
            //新动态
            NSArray *newCommentArray = [UserCenter sharedInstance].statusManager.classNewCommentArray;
            
            for (ClassInfo *classInfo in [UserCenter sharedInstance].curSchool.classes)
            {
                NSString *badge = nil;
                NSInteger commentNum = 0;
                for (TimelineCommentItem *commentItem in newCommentArray)
                {
                    if([commentItem.classID isEqualToString:classInfo.classID] && commentItem.alertInfo.num > 0)
                        commentNum += commentItem.alertInfo.num;
                }
                
                if(commentNum > 0)
                    badge = kStringFromValue(commentNum);
                else
                {
                    //新日志
                    NSArray *newFeedArray = [UserCenter sharedInstance].statusManager.feedClassesNew;
                    NSInteger num = 0;
                    for (ClassFeedNotice *noticeItem in newFeedArray)
                    {
                        if([noticeItem.schoolID isEqualToString:[UserCenter sharedInstance].curSchool.schoolID] && [noticeItem.classID isEqualToString:classInfo.classID])
                        {
                            num += noticeItem.num;
                        }
                    }
                    if(num > 0)
                        badge = @"";
                    else
                        badge = nil;
                }
                [classInfoDic setValue:badge forKey:classInfo.classID];
            }
            
            ClassSelectionVC *selectionVC = [[ClassSelectionVC alloc] init];
            [selectionVC setShowNew:YES];
            [selectionVC setClassInfoDic:classInfoDic];
            [selectionVC setSelection:^(ClassInfo *classInfo) {
                ClassZoneVC *classZoneVC = [[ClassZoneVC alloc] init];
                [classZoneVC setClassInfo:classInfo];
                [CurrentROOTNavigationVC pushViewController:classZoneVC animated:YES];
            }];
            [CurrentROOTNavigationVC pushViewController:selectionVC animated:YES];
        }
        else if([host isEqualToString:@"record"])//家园手册
        {
            if([UserCenter sharedInstance].curSchool.classes.count == 0)
            {
                ClassSelectionVC *selectionVC = [[ClassSelectionVC alloc] init];
                [selectionVC setSelection:^(ClassInfo *classInfo) {
                    GrowthTimelineVC *growthTimelineVC = [[GrowthTimelineVC alloc] init];
                    [growthTimelineVC setClassID:classInfo.classID];
                    [growthTimelineVC setTitle:classInfo.className];
                    [CurrentROOTNavigationVC pushViewController:growthTimelineVC animated:YES];
                }];
                [CurrentROOTNavigationVC pushViewController:selectionVC animated:YES];
            }
            else
            {
                PublishGrowthTimelineVC *publishGrowthTimelineVC = [[PublishGrowthTimelineVC alloc] init];
                [CurrentROOTNavigationVC pushViewController:publishGrowthTimelineVC animated:YES];
            }
            
        }
        else if([host isEqualToString:@"class_album"])//版相册
        {
            ClassSelectionVC *selectionVC = [[ClassSelectionVC alloc] init];
            [selectionVC setSelection:^(ClassInfo *classInfo) {
                PhotoFlowVC *albumVC = [[PhotoFlowVC alloc] init];
                [albumVC setClassID:classInfo.classID];
                [CurrentROOTNavigationVC pushViewController:albumVC animated:YES];
            }];
            [CurrentROOTNavigationVC pushViewController:selectionVC animated:YES];
        }
        else if([host isEqualToString:@"practice"])//联系
        {
            HomeWorkVC *homeWorkVC = [[HomeWorkVC alloc] init];
            [CurrentROOTNavigationVC pushViewController:homeWorkVC animated:YES];
        }
        else if([host isEqualToString:@"leave"])//考勤
        {
            ClassAttendanceVC *classAttendanceVC = [[ClassAttendanceVC alloc] init];
            [CurrentROOTNavigationVC pushViewController:classAttendanceVC animated:YES];
        }
        else if ([host isEqualToString:@"account"])//炼制账户
        {
            LZAccountVC *accountVC = [[LZAccountVC alloc] init];
            [CurrentROOTNavigationVC pushViewController:accountVC animated:YES];
        }
        else if([host isEqualToString:@"leave_my_record"])//我的考勤
        {
            MyAttendanceVC *myAttendanceVC = [[MyAttendanceVC alloc] init];
            [CurrentROOTNavigationVC pushViewController:myAttendanceVC animated:YES];
        }
    }

}

//- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    return self.appItems.count;
//}
//
//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    ApplicationItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ApplicationItemCell" forIndexPath:indexPath];
//    ApplicationItem *item = self.appItems[indexPath.row];
//    [cell setAppItem:item];
//    if([item.name isEqualToString:@"班博客"])
//    {
//        //新动态
//        NSArray *newCommentArray = [UserCenter sharedInstance].statusManager.classNewCommentArray;
//        NSInteger commentNum = 0;
//        for (ClassInfo *classInfo in [UserCenter sharedInstance].curSchool.classes)
//        {
//            for (TimelineCommentItem *commentItem in newCommentArray)
//            {
//                if([commentItem.classID isEqualToString:classInfo.classID] && commentItem.alertInfo.num > 0)
//                    commentNum += commentItem.alertInfo.num;
//            }
//        }
//        if(commentNum > 0)
//            [cell setBadge:kStringFromValue(commentNum)];
//        else
//        {
//            //新日志
//            NSArray *newFeedArray = [UserCenter sharedInstance].statusManager.feedClassesNew;
//            NSInteger num = 0;
//            for (ClassFeedNotice *noticeItem in newFeedArray)
//            {
//                if([noticeItem.schoolID isEqualToString:[UserCenter sharedInstance].curSchool.schoolID])
//                {
//                    num += noticeItem.num;
//                }
//            }
//            if(num > 0)
//                [cell setBadge:@""];
//            else
//                [cell setBadge:nil];
//        }
//    }
//    else
//        [cell setBadge:nil];
//    return cell;
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSInteger row = indexPath.row;
//    ApplicationItem *item = self.appItems[row];
//    NSString *url = item.url;
//    if([url hasPrefix:@"http"])
//    {
//        TNBaseWebViewController *webVC = [[TNBaseWebViewController alloc] init];
//        [webVC setUrl:url];
//        [CurrentROOTNavigationVC pushViewController:webVC animated:YES];
//    }
//    else if([url hasPrefix:@"lianzhi://"])
//    {
//        NSURL *path = [NSURL URLWithString:url];
//        NSString *host = path.host;
//        if([host isEqualToString:@"notice"])//发通知
//        {
//            [CurrentROOTNavigationVC pushViewController:[NotificationToAllVC sharedInstance] animated:YES];
//        }
//        else if([host isEqualToString:@"contact"])//联系人
//        {
//            ContactListVC *contactListVC = [[ContactListVC alloc] init];
//            [CurrentROOTNavigationVC pushViewController:contactListVC animated:YES];
//        }
//        else if([host isEqualToString:@"class"])//班博客
//        {
//            ClassSelectionVC *selectionVC = [[ClassSelectionVC alloc] init];
//            [selectionVC setSelection:^(ClassInfo *classInfo) {
//                ClassZoneVC *classZoneVC = [[ClassZoneVC alloc] init];
//                [classZoneVC setClassInfo:classInfo];
//                [CurrentROOTNavigationVC pushViewController:classZoneVC animated:YES];
//            }];
//            [CurrentROOTNavigationVC pushViewController:selectionVC animated:YES];
//        }
//        else if([host isEqualToString:@"record"])//家园手册
//        {
//            if([UserCenter sharedInstance].curSchool.classes.count == 0)
//            {
//                ClassSelectionVC *selectionVC = [[ClassSelectionVC alloc] init];
//                [selectionVC setSelection:^(ClassInfo *classInfo) {
//                    GrowthTimelineVC *growthTimelineVC = [[GrowthTimelineVC alloc] init];
//                    [growthTimelineVC setClassID:classInfo.classID];
//                    [growthTimelineVC setTitle:classInfo.className];
//                    [CurrentROOTNavigationVC pushViewController:growthTimelineVC animated:YES];
//                }];
//                [CurrentROOTNavigationVC pushViewController:selectionVC animated:YES];
//            }
//            else
//            {
//                PublishGrowthTimelineVC *publishGrowthTimelineVC = [[PublishGrowthTimelineVC alloc] init];
//                [CurrentROOTNavigationVC pushViewController:publishGrowthTimelineVC animated:YES];
//            }
//
//        }
//        else if([host isEqualToString:@"album"])//版相册
//        {
//            ClassSelectionVC *selectionVC = [[ClassSelectionVC alloc] init];
//            [selectionVC setSelection:^(ClassInfo *classInfo) {
//                PhotoFlowVC *albumVC = [[PhotoFlowVC alloc] init];
//                [albumVC setClassID:classInfo.classID];
//                [CurrentROOTNavigationVC pushViewController:albumVC animated:YES];
//            }];
//            [CurrentROOTNavigationVC pushViewController:selectionVC animated:YES];
//        }
//    }

    
//}
@end
