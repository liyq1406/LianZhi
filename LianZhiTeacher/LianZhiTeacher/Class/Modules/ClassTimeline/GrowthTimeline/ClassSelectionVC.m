//
//  ClassSelectionVC.m
#define kSectionHea
//  LianZhiTeacher
//
//  Created by jslsxu on 15/9/24.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import "ClassSelectionVC.h"
#import "ContactItemCell.h"

@interface ClassSelectionVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)NSArray *classArray;
@end

@implementation ClassSelectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我所有的班";
    
    self.classArray = [UserCenter sharedInstance].curSchool.allClasses;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 64) style:UITableViewStylePlain];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setSeparatorColor:kSepLineColor];
    [self.view addSubview:_tableView];
    
}

#pragma mark - UITableviewdele

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.classArray.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return kSectionHeaderHeight;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    NSDictionary *groupDic = self.classArray[section];
//    NSString *title = groupDic[@"groupName"];
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, kSectionHeaderHeight)];
//    [headerView setBackgroundColor:[UIColor whiteColor]];
//
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, headerView.width - 15, headerView.height)];
//    [titleLabel setTextColor:[UIColor colorWithHexString:@"8e8e8e"]];
//    [titleLabel setFont:[UIFont systemFontOfSize:14]];
//    [titleLabel setText:title];
//    [headerView addSubview:titleLabel];
//    
//    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, headerView.height - kLineHeight, headerView.width, kLineHeight)];
//    [bottomLine setBackgroundColor:kSepLineColor];
//    [headerView addSubview:bottomLine];
//    return headerView;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseID = @"ClassItemCell";
    ClassItemCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    if(nil == cell)
    {
        cell = [[ClassItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseID];
        [cell.chatButton setHidden:YES];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:13]];
        [cell.detailTextLabel setTextColor:kCommonTeacherTintColor];
    }
    
    ClassInfo *classInfo = self.classArray[indexPath.row];
    [cell setClassInfo:classInfo];
    BOOL isSelected = [self.originalClassID isEqualToString:classInfo.classID];
    if(isSelected)
    {
        [cell.redDot setHidden:YES];
        [cell.detailTextLabel setText:@"当前"];
        [cell setAccessoryView:nil];
    }
    else
    {
        if(self.showNew)
        {
            NSArray *newCommentArray = [UserCenter sharedInstance].statusManager.classNewCommentArray;
            NSInteger commentNum = 0;
            for (TimelineCommentItem *commentItem in newCommentArray)
            {
                if([commentItem.classID isEqualToString:classInfo.classID] && commentItem.alertInfo.num > 0)
                    commentNum += commentItem.alertInfo.num;
            }
            if(commentNum > 0)
                [cell.redDot setHidden:NO];
            else
            {
                //新日志
                NSArray *newFeedArray = [UserCenter sharedInstance].statusManager.feedClassesNew;
                NSInteger num = 0;
                for (ClassFeedNotice *noticeItem in newFeedArray)
                {
                    if([noticeItem.classID isEqualToString:classInfo.classID])
                    {
                        num += noticeItem.num;
                    }
                }
                if(num > 0)
                    [cell.redDot setHidden:NO];
                else
                    [cell.redDot setHidden:YES];
            }
        }
        else
            [cell.redDot setHidden:YES];
        
        [cell.detailTextLabel setText:nil];
        [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RightArrow"]]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ClassInfo *classInfo = self.classArray[indexPath.row];
    self.originalClassID = classInfo.classID;
    [tableView reloadData];
    if(self.selection)
        self.selection(classInfo);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
