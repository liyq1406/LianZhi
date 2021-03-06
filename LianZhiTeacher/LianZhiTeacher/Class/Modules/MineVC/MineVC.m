//
//  MineVC.m
//  LianZhiTeacher
//
//  Created by jslsxu on 15/8/12.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import "MineVC.h"
#import "PersonalInfoVC.h"
#import "ContactServiceVC.h"
#import "RelatedInfoVC.h"
#import "PersonalSettingVC.h"
#import "AboutVC.h"
#define kUserInfoCellHeight                     75

@implementation UserInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        _avatarView = [[AvatarView alloc] initWithFrame:CGRectMake(16, 10, 55, 55)];
        [self addSubview:_avatarView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_nameLabel setTextColor:[UIColor colorWithHexString:@"2c2c2c"]];
        [_nameLabel setFont:[UIFont systemFontOfSize:14]];
        [self addSubview:_nameLabel];
        
        _genderView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [_genderView setContentMode:UIViewContentModeCenter];
        [self addSubview:_genderView];
        
        _idLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [_idLabel setTextColor:[UIColor lightGrayColor]];
        [_idLabel setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:_idLabel];
    }
    return self;
}

- (void)refresh
{
    [_avatarView setImageWithUrl:[NSURL URLWithString:[UserCenter sharedInstance].userInfo.avatar]];
    [_nameLabel setText:[UserCenter sharedInstance].userInfo.name];
    [_nameLabel sizeToFit];
    [_nameLabel setOrigin:CGPointMake(_avatarView.right + 10, 18)];
    
    GenderType gender = [UserCenter sharedInstance].userInfo.gender;
    if(gender == GenderFemale)
        [_genderView setImage:[UIImage imageNamed:(@"GenderFemale")]];
    else
        [_genderView setImage:[UIImage imageNamed:(@"GenderMale")]];
    [_genderView setFrame:CGRectMake(_nameLabel.right + 5, _nameLabel.y, 16, 16)];
    
    [_idLabel setText:[NSString stringWithFormat:@"连枝号:%@",[UserCenter sharedInstance].userInfo.uid]];
    [_idLabel sizeToFit];
    [_idLabel setOrigin:CGPointMake(_avatarView.right + 10, kUserInfoCellHeight - 18 - _idLabel.height)];

}
@end


@interface MineVC ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)NSArray *titleArray;
@property (nonatomic, strong)NSArray *imageArray;
@property (nonatomic, strong)NSArray *actionArray;
@end

@implementation MineVC
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.titleArray = @[@[@"我的学校",@"系统设置"],@[@"关于连枝",@"联系客服"]];
        self.imageArray = @[@[@"IconMySchool",@"IconSetting"],@[@"IconAbout",@"IconContact"]];
        self.actionArray = @[@[@"RelatedInfoVC",@"PersonalSettingVC"],@[@"AboutVC",@"ContactServiceVC"]];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [_tableView setSeparatorColor:kCommonSeparatorColor];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:_tableView];
    
    //加载设置
    [[UserCenter sharedInstance] requestNoDisturbingTime];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 + self.titleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return 1;
    else
    {
        NSArray *titleArray = self.titleArray[section - 1];
        return titleArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
        return kUserInfoCellHeight;
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSString *reuseID = nil;
    if(section == 0)
    {
        reuseID = @"UserInfoCell";
        UserInfoCell *cell = (UserInfoCell *)[tableView dequeueReusableCellWithIdentifier:reuseID];
        if(cell == nil)
        {
            cell = [[UserInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
            [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RightArrow"]]];
        }
        [cell refresh];
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
        if(nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
            [cell.textLabel setTextColor:[UIColor colorWithHexString:@"2c2c2c"]];
            [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
            [cell setAccessoryView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RightArrow"]]];
        }
        NSInteger row = indexPath.row;
        if(section > 0)
        {
            NSString *title = self.titleArray[section - 1][row];
            [cell.textLabel setText:title];
            [cell.imageView setImage:[UIImage imageNamed:self.imageArray[section - 1][row]]];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if(section == 0)
    {
        PersonalInfoVC *personalInfoVC = [[PersonalInfoVC alloc] init];
        [CurrentROOTNavigationVC pushViewController:personalInfoVC animated:YES];
    }
    else
    {
        TNBaseViewController *actionVC = [[NSClassFromString(self.actionArray[section - 1][row]) alloc] init];
        [CurrentROOTNavigationVC pushViewController:actionVC animated:YES];
    }
}
@end
