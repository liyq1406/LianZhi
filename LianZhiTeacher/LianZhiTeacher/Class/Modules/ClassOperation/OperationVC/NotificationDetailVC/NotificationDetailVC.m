//
//  NotificationDetailVC.m
//  LianZhiTeacher
//
//  Created by jslsxu on 15/10/1.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import "NotificationDetailVC.h"
#import "CollectionImageCell.h"
#import "MessageSendVC.h"
#import "TextMessageSendVC.h"
#import "PhotoOperationVC.h"
#import "AudioMessageSendVC.h"
#import "NotificationClassStudentsVC.h"
#import "NotificationGroupMemberVC.h"
#import "NotificationTargetVC.h"
@interface NotificationDetailVC ()<UICollectionViewDataSource, UICollectionViewDelegate>

@end

@implementation NotificationDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息详情";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"转发" style:UIBarButtonItemStylePlain target:self action:@selector(onSendNextClicked)];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 64) style:UITableViewStyleGrouped];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorColor:kSepLineColor];
    [self.view addSubview:_tableView];
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
    [self setupHeaderView:_headerView];
    [_tableView setTableHeaderView:_headerView];
}

- (void)setupHeaderView:(UIView *)viewParent
{
    UIView *contentView = [[UIView alloc] initWithFrame:viewParent.bounds];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [viewParent addSubview:contentView];
    
    NSInteger spaceYStart = 15;
    NSString *words = self.notificationItem.words;
    if(words.length > 0)
    {
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, spaceYStart, viewParent.width - 10 * 2, 0)];
        [contentLabel setTextColor:[UIColor colorWithHexString:@"2c2c2c"]];
        [contentLabel setFont:[UIFont systemFontOfSize:12]];
        [contentLabel setNumberOfLines:0];
        [contentLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [contentLabel setText:words];
        [contentLabel sizeToFit];
        [contentView addSubview:contentLabel];
        
        spaceYStart += contentLabel.height + 10;
    }
    
    if(self.notificationItem.audioItem)
    {
        _voiceButton = [[MessageVoiceButton alloc] initWithFrame:CGRectMake(20, spaceYStart, viewParent.width / 2, 35)];
        [_voiceButton addTarget:self action:@selector(onVoiceClicked) forControlEvents:UIControlEventTouchUpInside];
        [_voiceButton setAudioItem:self.notificationItem.audioItem];
        [contentView addSubview:_voiceButton];
        
        [_voiceButton setVoiceWithURL:[NSURL URLWithString:self.notificationItem.audioItem.audioUrl] withAutoPlay:NO];
        
        UILabel *spanLabel = [[UILabel alloc] initWithFrame:CGRectMake(_voiceButton.right, _voiceButton.y, 60, _voiceButton.height)];
        [spanLabel setTextColor:[UIColor colorWithHexString:@"8f8f8f"]];
        [spanLabel setFont:[UIFont systemFontOfSize:10]];
        [spanLabel setText:[Utility formatStringForTime:self.notificationItem.audioItem.timeSpan]];
        [spanLabel sizeToFit];
        [spanLabel setOrigin:CGPointMake(_voiceButton.right + 10, spaceYStart + (_voiceButton.height - spanLabel.height) / 2)];
        [contentView addSubview:spanLabel];
        
        spaceYStart += 35 + 10;
    }
    
    if(self.notificationItem.photoArray.count > 0)
    {
        NSInteger count = self.notificationItem.photoArray.count;
        NSInteger itemWidth = 80;
        NSInteger innerMargin = 5;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        [layout setItemSize:CGSizeMake(itemWidth, itemWidth)];
        [layout setMinimumInteritemSpacing:innerMargin];
        [layout setMinimumLineSpacing:innerMargin];
        
        NSInteger row = (count + 2) / 3;
        NSInteger width = row > 1 ? (itemWidth * 3 + innerMargin * 2) : (itemWidth * count + innerMargin * (count - 1));
        NSInteger height = itemWidth  * row + innerMargin * (row - 1);
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake((viewParent.width - width) / 2, spaceYStart, width, height) collectionViewLayout:layout];
        [collectionView setBackgroundColor:[UIColor clearColor]];
        [collectionView setShowsHorizontalScrollIndicator:NO];
        [collectionView setShowsVerticalScrollIndicator:NO];
        [collectionView setScrollsToTop:NO];
        [collectionView setDelegate:self];
        [collectionView setDataSource:self];
        [collectionView registerClass:[CollectionImageCell class] forCellWithReuseIdentifier:@"CollectionImageCell"];
        [contentView addSubview:collectionView];
        
        spaceYStart += height + 10;
    }
    
    UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(0, spaceYStart, viewParent.width, kLineHeight)];
    [sepLine setBackgroundColor:kSepLineColor];
    [contentView addSubview:sepLine];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [timeLabel setTextColor:[UIColor colorWithHexString:@"9a9a9a"]];
    [timeLabel setFont:[UIFont systemFontOfSize:10]];
    [timeLabel setText:self.notificationItem.ctime];
    [timeLabel sizeToFit];
    [timeLabel setOrigin:CGPointMake(10, sepLine.bottom + (22 - timeLabel.height) / 2)];
    [contentView addSubview:timeLabel];
    
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [numLabel setTextColor:[UIColor colorWithHexString:@"9a9a9a"]];
    [numLabel setFont:[UIFont systemFontOfSize:10]];
    [numLabel setText:[NSString stringWithFormat:@"已发送%ld人",(long)self.notificationItem.sentNum]];
    [numLabel sizeToFit];
    [numLabel setOrigin:CGPointMake(viewParent.width - 10 - numLabel.width, sepLine.bottom + (22 - numLabel.height) / 2)];
    [contentView addSubview:numLabel];
    spaceYStart += 22;
    [contentView setHeight:spaceYStart];
    
    spaceYStart += 16;
    [viewParent setHeight:spaceYStart];
}

- (void)onVoiceClicked
{
    [_voiceButton setVoiceWithURL:[NSURL URLWithString:self.notificationItem.audioItem.audioUrl] withAutoPlay:YES];
}

- (void)onSendNextClicked
{
    MessageSendVC *messageSendVC = nil;
    if(self.notificationItem.photoArray.count > 0)
    {
        PhotoOperationVC *photoOperationVC = [[PhotoOperationVC alloc] init];
        [photoOperationVC setOriginalImageArray:self.notificationItem.photoArray];
        
        messageSendVC = photoOperationVC;
    }
    else if(self.notificationItem.audioItem)
    {
        AudioMessageSendVC *audioVC = [[AudioMessageSendVC alloc] init];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.notificationItem.audioItem.audioUrl]];
        [audioVC setAmrData:[[MLDataCache shareInstance] cachedDataForRequest:request]];
        [audioVC setDuration:self.notificationItem.audioItem.timeSpan];
        messageSendVC = audioVC;
    }
    else
    {
        TextMessageSendVC *textVC = [[TextMessageSendVC alloc] init];
        
        
        messageSendVC = textVC;
    }
    [messageSendVC setWords:self.notificationItem.words];
    TNBaseNavigationController *nav = [[TNBaseNavigationController alloc] initWithRootViewController:messageSendVC];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return self.notificationItem.sentTarget.classArray.count;
    else if(section == 1)
        return self.notificationItem.sentTarget.managedClassArray.count;
    else
        return self.notificationItem.sentTarget.groupArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 45)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, headerView.width - 12 * 2, headerView.height)];
    [titleLabel setTextColor:[UIColor colorWithHexString:@"2c2c2c"]];
    [titleLabel setFont:[UIFont systemFontOfSize:14]];
    if(section == 0)
        [titleLabel setText:@"我教授的班"];
    else if(section == 1)
        [titleLabel setText:@"我管理的班"];
    else
        [titleLabel setText:@"同事组"];
    [headerView addSubview:titleLabel];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID];
        [cell.textLabel setTextColor:[UIColor colorWithHexString:@"767676"]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:12]];
        [cell.detailTextLabel setTextColor:[UIColor colorWithHexString:@"9a9a9a"]];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:10]];
    }
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if(section == 0)
    {
        SentClassInfo *classInfo = self.notificationItem.sentTarget.classArray[row];
        [cell.textLabel setText:classInfo.name];
        [cell.detailTextLabel setText:[NSString stringWithFormat:@"%ld/%ld",classInfo.sentNum, classInfo.totalNum]];
    }
    else if(section == 1)
    {
        SentClassInfo *classInfo = self.notificationItem.sentTarget.managedClassArray[row];
        [cell.textLabel setText:classInfo.name];
        [cell.detailTextLabel setText:kStringFromValue(classInfo.sentNum)];
    }
    else
    {
        SentGroup *group = self.notificationItem.sentTarget.groupArray[row];
        [cell.textLabel setText:group.groupName];
        [cell.detailTextLabel setText:kStringFromValue(group.sentNum)];
    }
//    [cell.textLabel setText:];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    NotificationTargetVC *notificationTargetVC = [[NotificationTargetVC alloc] init];
    if(section == 0)
    {
        SentClassInfo *classInfo = self.notificationItem.sentTarget.classArray[row];
        [notificationTargetVC setSelectedArray:classInfo.sendStudents];
        [notificationTargetVC setGroupID:classInfo.classID];
    }
    else if(section == 1)
    {
        SentClassInfo *classInfo = self.notificationItem.sentTarget.managedClassArray[row];
        [notificationTargetVC setSelectedArray:classInfo.sendStudents];
        [notificationTargetVC setGroupID:classInfo.classID];
    }
    else
    {
        SentGroup *group = self.notificationItem.sentTarget.groupArray[row];
        [notificationTargetVC setGroupID:group.groupID];
        [notificationTargetVC setSelectedArray:group.sendTeachers];
    }
    [self.navigationController pushViewController:notificationTargetVC animated:YES];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.notificationItem.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionImageCell" forIndexPath:indexPath];
    [cell setItem:self.notificationItem.photoArray[indexPath.row]];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
