//
//  NotificationToAllVC.m
//  LianZhiTeacher
//
//  Created by jslsxu on 15/1/30.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import "NotificationToAllVC.h"
#import "TextMessageSendVC.h"
#import "PhotoOperationVC.h"
#import "AudioMessageSendVC.h"
#import "NotificationDetailVC.h"

@implementation SentClassInfo

- (void)parseData:(TNDataWrapper *)dataWrapper
{
    self.classID = [dataWrapper getStringForKey:@"classid"];
    self.sentNum = [dataWrapper getIntegerForKey:@"sent_num"];
    self.name = [dataWrapper getStringForKey:@"name"];
    self.totalNum = [dataWrapper getIntegerForKey:@"students_num"];
}

@end

@implementation SentGroup

- (void)parseData:(TNDataWrapper *)dataWrapper
{
    self.groupID = [dataWrapper getStringForKey:@"id"];
    self.groupName = [dataWrapper getStringForKey:@"name"];
    self.sentNum = [dataWrapper getIntegerForKey:@"sent_num"];
    self.totalNum = [dataWrapper getIntegerForKey:@"students_num"];
}

@end

@implementation SentTarget

- (void)parseData:(TNDataWrapper *)dataWrapper
{
    TNDataWrapper *classesWrapper = [dataWrapper getDataWrapperForKey:@"classes"];
    if(classesWrapper.count > 0)
    {
        NSMutableArray *classArray = [NSMutableArray array];
        for (NSInteger i = 0; i < classesWrapper.count; i++)
        {
            TNDataWrapper *classItemWrapper = [classesWrapper getDataWrapperForIndex:i];
            SentClassInfo *classInfo = [[SentClassInfo alloc] init];
            [classInfo parseData:classItemWrapper];
            [classArray addObject:classInfo];
        }
        self.classArray = classArray;
    }
    
    TNDataWrapper *groupsWrapper = [dataWrapper getDataWrapperForKey:@"groups"];
    if(groupsWrapper.count > 0)
    {
        NSMutableArray *groupArray = [NSMutableArray array];
        for (NSInteger i = 0; i < classesWrapper.count; i++)
        {
            TNDataWrapper *groupItemWrapper = [classesWrapper getDataWrapperForIndex:i];
            SentGroup *groupInfo = [[SentGroup alloc] init];
            [groupInfo parseData:groupItemWrapper];
            [groupArray addObject:groupInfo];
        }
        self.groupArray = groupArray;
    }
}

@end

@implementation NotificationItem
- (void)parseData:(TNDataWrapper *)dataWrapper
{
    self.notificationID = [dataWrapper getStringForKey:@"id"];
    self.words = [dataWrapper getStringForKey:@"words"];
    self.ctime = [dataWrapper getStringForKey:@"created_time"];
    self.sentNum = [dataWrapper getIntegerForKey:@"sent_num"];
    self.notificationType = 1;
    TNDataWrapper *audioWrapper = [dataWrapper getDataWrapperForKey:@"voice"];
    if(audioWrapper.count > 0)
    {
        self.notificationType = 2;
        AudioItem *audioItem = [[AudioItem alloc] init];
        [audioItem parseData:audioWrapper];
        self.audioItem = audioItem;
        
        if(self.words.length == 0)
            self.words = @"发送了一条语音消息";
    }
    
    TNDataWrapper *photoWrapper = [dataWrapper getDataWrapperForKey:@"pictures"];
    if(photoWrapper.count > 0)
    {
        self.notificationType = 3;
        NSMutableArray *photoArray = [NSMutableArray array];
        for (NSInteger i = 0; i < photoWrapper.count; i++)
        {
            TNDataWrapper *photoItemWrapper = [photoWrapper getDataWrapperForIndex:i];
            PhotoItem *photoItem = [[PhotoItem alloc] initWithDataWrapper:photoItemWrapper];
            [photoArray addObject:photoItem];
        }
        self.photoArray = photoArray;
        
        if(self.words.length == 0)
            self.words = [NSString stringWithFormat:@"发送了%ld张照片",self.photoArray.count];
    }
    
    TNDataWrapper *sentTargetWrapper = [dataWrapper getDataWrapperForKey:@"target"];
    if(sentTargetWrapper.count > 0)
    {
        SentTarget *target = [[SentTarget alloc] init];
        [target parseData:sentTargetWrapper];
        self.sentTarget = target;
    }
}

@end

@implementation NotificationModel
- (BOOL)hasMoreData
{
    return self.total > self.modelItemArray.count;
}

- (BOOL)parseData:(TNDataWrapper *)data type:(REQUEST_TYPE)type
{
    if(type == REQUEST_REFRESH)
        [self.modelItemArray removeAllObjects];
    TNDataWrapper *listWrapper = [data getDataWrapperForKey:@"list"];
    if(listWrapper.count > 0)
    {
        for (NSInteger i = 0; i < listWrapper.count; i++)
        {
            NotificationItem *item = [[NotificationItem alloc] init];
            TNDataWrapper *itemWrapper = [listWrapper getDataWrapperForIndex:i];
            [item parseData:itemWrapper];
            [self.modelItemArray addObject:item];
        }
    }
    self.total = [data getIntegerForKey:@"total"];
    return YES;
}

@end

@implementation NotificationCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if(self)
    {
        [self setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RightArrow"]]];
        
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_contentLabel setTextColor:self.textLabel.textColor];
        [_contentLabel setFont:[UIFont systemFontOfSize:13]];
        [self addSubview:_contentLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_timeLabel setFont:[UIFont systemFontOfSize:11]];
        [_timeLabel setTextColor:self.detailTextLabel.textColor];
        [self addSubview:_timeLabel];
        
        _sepLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - kLineHeight, self.width, kLineHeight)];
        [_sepLine setBackgroundColor:kSepLineColor];
        [self addSubview:_sepLine];
    }
    return self;
}
- (void)onReloadData:(TNModelItem *)modelItem
{
    NotificationItem *item = (NotificationItem *)modelItem;
    NSString *imageStr = nil;
    if(item.notificationType == 1)//文字
        imageStr = @"NotiRecordTextIcon";
    else if(item.notificationType == 2)//语音
        imageStr = @"NotiRecordAudioIcon";
    else
        imageStr = @"NotiRecordPhotoIcon";
    [self.imageView setImage:[UIImage imageNamed:imageStr]];
    [_timeLabel setText:item.ctime];
    [_timeLabel sizeToFit];
    [_timeLabel setOrigin:CGPointMake(self.width - 30 - _timeLabel.width, (self.height - _timeLabel.height) / 2)];
    [_contentLabel setText:item.words];
    [_contentLabel sizeToFit];
    [_contentLabel setFrame:CGRectMake(45, (self.height - _contentLabel.height) / 2, MIN(_contentLabel.width, _timeLabel.left - 10 - 45), _contentLabel.height)];
}

+ (NSNumber *)cellHeight:(TNModelItem *)modelItem cellWidth:(NSInteger)width
{
    return @(44);
}

@end

@interface NotificationToAllVC()

@end

@implementation NotificationToAllVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self requestData:REQUEST_REFRESH];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"发布通知";
    
    UIView *operationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 75)];
    [operationView setBackgroundColor:kCommonTeacherTintColor];
    [self setupHeaderView:operationView];
    [self.view addSubview:operationView];
    
    [_tableView setFrame:CGRectMake(0, operationView.bottom, self.view.width, self.view.height - operationView.bottom)];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.width, 30)];
    [headerView setBackgroundColor:[UIColor colorWithHexString:@"E6E6E6"]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, headerView.width - 10 * 2, headerView.height)];
    [titleLabel setTextColor:[UIColor colorWithHexString:@"8f8f8f"]];
    [titleLabel setFont:[UIFont systemFontOfSize:12]];
    [titleLabel setText:@"近期发送记录"];
    [headerView addSubview:titleLabel];
    [_tableView setTableHeaderView:headerView];
    [self bindTableCell:@"NotificationCell" tableModel:@"NotificationModel"];
    [self setSupportPullDown:YES];
    [self setSupportPullUp:YES];

}

- (HttpRequestTask *)makeRequestTaskWithType:(REQUEST_TYPE)requestType
{
    
    HttpRequestTask *task = [[HttpRequestTask alloc] init];
    [task setRequestUrl:@"notice/my_send_list"];
    [task setRequestMethod:REQUEST_GET];
    [task setRequestType:requestType];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(requestType == REQUEST_GETMORE)
        [params setValue:kStringFromValue(self.tableViewModel.modelItemArray.count) forKey:@"from"];
    [task setParams:params];
    [task setObserver:self];
    return task;
}

- (void)setupHeaderView:(UIView *)viewParent
{
    NSInteger itemWidth = 50;
    NSInteger itemHeight = 60;
    NSInteger innerMagin = 36;
    NSInteger spaceXStart = (viewParent.width - itemWidth * 3 - innerMagin * 2) / 2;
    NSArray *imageArray = @[@"NotificationMessage",@"NotificationPhoto",@"NotificationAudio"];
    NSArray *titleArray = @[@"消息通知",@"图片通知",@"语音通知"];
    for (NSInteger i = 0; i < 3; i++)
    {
        LZTabBarButton *sendButton = [LZTabBarButton buttonWithType:UIButtonTypeCustom];
        [sendButton setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        [sendButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendButton setTitle:titleArray[i] forState:UIControlStateNormal];
        [sendButton addTarget:self action:NSSelectorFromString([NSString stringWithFormat:@"on%@",imageArray[i]]) forControlEvents:UIControlEventTouchUpInside];
        [sendButton setFrame:CGRectMake(spaceXStart + (itemWidth + innerMagin) * i, (viewParent.height - itemHeight) / 2, itemWidth, itemHeight)];
        [viewParent addSubview:sendButton];
    }
}

- (void)onNotificationMessage
{
    TextMessageSendVC *messageOperationVC = [[TextMessageSendVC alloc] init];
    TNBaseNavigationController *nav = [[TNBaseNavigationController alloc] initWithRootViewController:messageOperationVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)onNotificationPhoto
{
    PhotoOperationVC *photoOperationVC = [[PhotoOperationVC alloc] init];
    TNBaseNavigationController *nav = [[TNBaseNavigationController alloc] initWithRootViewController:photoOperationVC];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)onNotificationAudio
{
    AudioMessageSendVC *messageOperationVC = [[AudioMessageSendVC alloc] init];
    TNBaseNavigationController *nav = [[TNBaseNavigationController alloc] initWithRootViewController:messageOperationVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (void)TNBaseTableViewControllerItemSelected:(TNModelItem *)modelItem atIndex:(NSIndexPath *)indexPath
{
    NotificationDetailVC *notiDetailVC = [[NotificationDetailVC alloc] init];
    [notiDetailVC setNotificationItem:(NotificationItem *)modelItem];
    [self.navigationController pushViewController:notiDetailVC animated:YES];
}

@end
