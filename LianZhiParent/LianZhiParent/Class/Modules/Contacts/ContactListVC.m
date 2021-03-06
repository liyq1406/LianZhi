//
//  ContactListVC.m
//  LianZhiParent
//
//  Created by jslsxu on 14/12/17.
//  Copyright (c) 2014年 jslsxu. All rights reserved.
//

#import "ContactListVC.h"
#import "JSMessagesViewController.h"
#import "ClassMemberVC.h"
@implementation ClassParentsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        
    }
    return self;
}

@end

@implementation ContactListHeaderView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setBackgroundColor:[UIColor whiteColor]];
        _logoView = [[LogoView alloc] initWithFrame:CGRectMake(10, 3, (self.height - 3 * 2),self.height - 3 * 2)];
        [self addSubview:_logoView];
        
        _classLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_classLabel setBackgroundColor:[UIColor clearColor]];
        [_classLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [self addSubview:_classLabel];
        
        _schoolLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_schoolLabel setBackgroundColor:[UIColor clearColor]];
        [_schoolLabel setTextColor:[UIColor colorWithHexString:@"9a9a9a"]];
        [_schoolLabel setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:_schoolLabel];
        
        _numLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_numLabel setBackgroundColor:[UIColor clearColor]];
        [_numLabel setTextColor:[UIColor colorWithHexString:@"9a9a9a"]];
        [_numLabel setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:_numLabel];
        
        _sepLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - kLineHeight, self.width, kLineHeight)];
        [_sepLine setBackgroundColor:kSepLineColor];
        [self addSubview:_sepLine];
        
        _chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_chatButton setUserInteractionEnabled:NO];
        [_chatButton setFrame:CGRectMake(self.width - 40 - 10, (self.height - 30) / 2, 40, 30)];
//        [_chatButton addTarget:self action:@selector(onChatClicked) forControlEvents:UIControlEventTouchUpInside];
        [_chatButton setImage:[UIImage imageNamed:@"MassChatNormal"] forState:UIControlStateNormal];
        [_chatButton setImage:[UIImage imageNamed:@"MassChatHighlighted"] forState:UIControlStateHighlighted];
        [self addSubview:_chatButton];
        
        UIButton *coverButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [coverButton setFrame:self.bounds];
        [coverButton addTarget:self action:@selector(onCoverButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:coverButton];
    }
    return self;
}

- (void)setClassInfo:(ClassInfo *)classInfo
{
    _classInfo = classInfo;
    
    [_logoView setImageWithUrl:[NSURL URLWithString:classInfo.logo]];
    NSInteger vMargin = 12;
    [_classLabel setText:classInfo.className];
    [_classLabel sizeToFit];
    [_classLabel setOrigin:CGPointMake(_logoView.right + 5, vMargin)];
    
    [_schoolLabel setText:self.classInfo.schoolInfo.schoolName];
    [_schoolLabel sizeToFit];
    [_schoolLabel setOrigin:CGPointMake(_logoView.right + 5, self.height - _schoolLabel.height - vMargin)];
    
    [_numLabel setText:[NSString stringWithFormat:@"(共%ld位老师)",(long)_classInfo.teachers.count]];
    [_numLabel sizeToFit];
    [_numLabel setOrigin:CGPointMake(_classLabel.right + 10, _classLabel.y + (_classLabel.height - _numLabel.height) / 2)];
}

- (void)onCoverButtonClicked
{
    JSMessagesViewController *chatVC = [[JSMessagesViewController alloc] init];
    [chatVC setTo_objid:self.classInfo.schoolInfo.schoolID];
    [chatVC setTargetID:self.classInfo.classID];
    [chatVC setTitle:self.classInfo.className];
    [chatVC setChatType:ChatTypeClass];
    [ApplicationDelegate popAndPush:chatVC];
}

@end

@interface ContactListVC ()

@end

@implementation ContactListVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
  
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.view addSubview:_tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCurChildChanged) name:kUserCenterChangedCurChildNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onCurChildChanged) name:kUserInfoVCNeedRefreshNotificaiotn object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoChanged) name:kUserInfoChangedNotification object:nil];
}

- (void)onCurChildChanged
{
    [_tableView reloadData];
}

- (void)onUserInfoChanged
{
    [_tableView reloadData];
}

#pragma mark UItableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [UserCenter sharedInstance].curChild.classes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    ClassInfo *class = [UserCenter sharedInstance].curChild.classes[section];
    return class.teachers.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    ClassInfo *class = [UserCenter sharedInstance].curChild.classes[section];
    if(class.schoolInfo.classIMEnaled)
        return 60;
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ClassInfo *class = [UserCenter sharedInstance].curChild.classes[section];
    if(class.schoolInfo.classIMEnaled)
    {
        static NSString *reuseHeaderID = @"HeaderView";
        ContactListHeaderView *headerView = (ContactListHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:reuseHeaderID];
        if(headerView == nil)
        {
            headerView = [[ContactListHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 60)];
        }
        [headerView setClassInfo:class];
        return headerView;
    }
    else
        return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"ContactItemCell";
    ContactItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(cell == nil)
    {
        cell = [[ContactItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    ClassInfo *class = [UserCenter sharedInstance].curChild.classes[indexPath.section];
    NSArray *teachers = class.teachers;
    if(indexPath.row == teachers.count)
    {
        [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RightArrow"]]];
        [cell setStudetsParentsCell:YES];
    }
    else
    {
        [cell setStudetsParentsCell:NO];
        [cell setAccessoryView:nil];
        [cell setTeachInfo:[[class teachers] objectAtIndex:indexPath.row]];
        [cell setSchoolInfo:class.schoolInfo];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    ClassInfo *class = [UserCenter sharedInstance].curChild.classes[indexPath.section];
    if(row < class.teachers.count)
    {
        TeacherInfo *teacherInfo = [[class teachers] objectAtIndex:indexPath.row];
        if(teacherInfo.actived)
        {
            NSInteger section = indexPath.section;
            ClassInfo *classInfo = [UserCenter sharedInstance].curChild.classes[section];
            JSMessagesViewController *chatVC = [[JSMessagesViewController alloc] init];
            [chatVC setChatType:ChatTypeTeacher];
            [chatVC setTo_objid:classInfo.schoolInfo.schoolID];
            [chatVC setTargetID:teacherInfo.uid];
            [chatVC setMobile:teacherInfo.mobile];
            NSString *title = [NSString stringWithFormat:@"%@",teacherInfo.teacherName];
            if(teacherInfo.course)
                title = [NSString stringWithFormat:@"%@(%@)",title, teacherInfo.course];
            [chatVC setTitle:title];
            [ApplicationDelegate popAndPush:chatVC];
        }
        else
        {
            TNButtonItem *cancelItem = [TNButtonItem itemWithTitle:@"取消" action:nil];
            TNButtonItem *callItem = [TNButtonItem itemWithTitle:@"拨打电话" action:^{
                NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel://%@",teacherInfo.mobile];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            }];
            TNAlertView *alertView = [[TNAlertView alloc] initWithTitle:@"该用户尚未下载使用连枝，您可打电话与用户联系" buttonItems:@[cancelItem, callItem]];
            [alertView show];
        }
    }
    else
    {
        ClassMemberVC *classMemberVC = [[ClassMemberVC alloc] init];
        [classMemberVC setShowParentsOnly:YES];
        [classMemberVC setClassID:class.classID];
        [self.navigationController pushViewController:classMemberVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
