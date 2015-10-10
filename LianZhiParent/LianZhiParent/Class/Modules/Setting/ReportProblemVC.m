//
//  ReportProblemVC.m
//  LianZhiTeacher
//
//  Created by jslsxu on 15/2/6.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import "ReportProblemVC.h"

#define kReportContentMaxNum                500
@implementation ReportProblemVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.type == 1)
        self.title = @"软件错误报告";
    else if(self.type == 2)
        self.title = @"产品升级建议";
    else if(self.type == 3)
        self.title = @"关联信息报错";
    else
        self.title = @"登录信息修改";
    if(self.type == 1 || self.type == 2)
    {
        _sourceArray = @[
                         @{@"function":@"登录",@"component":@[@"忘记密码",@"手机号登陆",@"连枝号登录",@"新用户激活"]},
                         @{@"function":@"消息",@"component":@[@"消息通知",@"聊天"]},
                         @{@"function":@"联系人",@"component":@[@"家长沟通",@"班级群聊",@"家长之间沟通"]},
                         @{@"function":@"树屋",@"component":@[@"发布日志",@"评论点赞",@"增加标签",@"书屋相册"]},
                         @{@"function":@"班博客",@"component":@[@"空间相册",@"班应用",@"作业练习",@"家园手册",@"考勤记录"]},
                         @{@"function":@"发现",@"component":@[@"身边事",@"兴趣",@"常见问题",@"操作指南"]},
                         @{@"function":@"我",@"component":@[@"个人资料",@"孩子档案",@"家庭成员",@"个性设置"]},
                         @{@"function":@"其他",@"component":@[@"其他"]}];
    }
    else if(self.type == 3)
    {
        NSMutableArray *childrenArray = [NSMutableArray array];
        for (ChildInfo *childInfo in [UserCenter sharedInstance].children)
        {
            NSMutableDictionary *childParentDic = [NSMutableDictionary dictionary];
            [childParentDic setValue:childInfo.name forKey:@"function"];
            NSMutableArray *familyArray = [NSMutableArray array];
            for (FamilyInfo *familyInfo in childInfo.family)
            {
                if([[UserCenter sharedInstance].userInfo.uid isEqualToString:familyInfo.uid])
                    [familyArray addObject:@"本人"];
                else
                    [familyArray addObject:familyInfo.name];
            }
            [childParentDic setValue:familyArray forKey:@"component"];
            [childrenArray addObject:childParentDic];
        }
        _sourceArray = childrenArray;
    }
}

- (void)setupSubviews
{
    CGFloat margin = 15;
    NSInteger vMargin = 8;
    
    NSArray *functionArray = @[@"请选择功能类型",@"请选择功能类型",@"请选择关联错误的成员",@""];
    _contactField = [[LZTextField alloc] initWithFrame:CGRectMake(margin, margin, self.view.width - margin * 2, 40)];
    [_contactField setPlaceholder:@"请留下您的联系方式"];
    [_contactField setTextColor:[UIColor colorWithHexString:@"666666"]];
    [_contactField setReturnKeyType:UIReturnKeyDone];
    [_contactField setDelegate:self];
    [_contactField setFont:[UIFont systemFontOfSize:15]];
    [_contactField setText:[UserCenter sharedInstance].userInfo.mobile];
    [self.view addSubview:_contactField];
    
    CGFloat spaceYStart = _contactField.bottom + vMargin;
    
    if(self.type != 4)
    {
        _groupField = [[LZTextField alloc] initWithFrame:CGRectMake(margin, spaceYStart, self.view.width - margin * 2, 40)];
        [_groupField setPlaceholder:functionArray[self.type - 1]];
        [_groupField setTextColor:[UIColor colorWithHexString:@"666666"]];
        [_groupField setReturnKeyType:UIReturnKeyDone];
        [_groupField setDelegate:self];
        [_groupField setFont:[UIFont systemFontOfSize:15]];
        UIImageView *rightView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RightArrow"]];
        [rightView setOrigin:CGPointMake(_groupField.width - rightView.width - 10, (_groupField.height - rightView.height) / 2)];
        [_groupField addSubview:rightView];
        
        UIButton *coverButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [coverButton setFrame:_groupField.bounds];
        [coverButton addTarget:self action:@selector(onCoverButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_groupField addSubview:coverButton];
        [self.view addSubview:_groupField];
        spaceYStart += 40 + vMargin;
    }
    
    UIView *textViewBG = [[UIView alloc] initWithFrame:CGRectZero];
    [textViewBG setBackgroundColor:[UIColor whiteColor]];
    [textViewBG.layer setCornerRadius:4];
    [textViewBG.layer setBorderWidth:0.5];
    [textViewBG.layer setBorderColor:[UIColor colorWithHexString:@"D8D8D8"].CGColor];
    [textViewBG setFrame:CGRectMake(margin, spaceYStart, self.view.width - margin * 2, 100)];
    [self.view addSubview:textViewBG];
    
    _textView = [[UTPlaceholderTextView alloc] initWithFrame:CGRectMake(5, 5, textViewBG.width - 5 * 2, textViewBG.height - 5 - 20)];
    [_textView setPlaceholder:@"请输入要上报的内容"];
    [_textView setBackgroundColor:[UIColor clearColor]];
    [_textView setDelegate:self];
    [_textView setReturnKeyType:UIReturnKeyDone];
    [_textView setFont:[UIFont systemFontOfSize:15]];
    [_textView setTextColor:[UIColor colorWithHexString:@"666666"]];
    [textViewBG addSubview:_textView];
    
    _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(_textView.left, _textView.bottom, _textView.width, 20)];
    [_numLabel setTextColor:[UIColor lightGrayColor]];
    [_numLabel setFont:[UIFont systemFontOfSize:14]];
    [_numLabel setTextAlignment:NSTextAlignmentRight];
    [_numLabel setText:kStringFromValue(kReportContentMaxNum - _textView.text.length)];
    [textViewBG addSubview:_numLabel];
    
    _contactButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_contactButton addTarget:self action:@selector(onContactButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_contactButton setImage:[UIImage imageNamed:@"ControlDefault"] forState:UIControlStateNormal];
    [_contactButton setImage:[UIImage imageNamed:@"ControlSelected"] forState:UIControlStateSelected];
    [_contactButton setFrame:CGRectMake(margin - 4, textViewBG.bottom + 5, 20, 20)];
    [self.view addSubview:_contactButton];
    
    _hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(_contactButton.right + 5, _contactButton.y, 120, 20)];
    [_hintLabel setFont:[UIFont systemFontOfSize:12]];
    [_hintLabel setTextColor:[UIColor colorWithHexString:@"8f8f8f"]];
    [_hintLabel setText:@"需要客服与您联系"];
    [self.view addSubview:_hintLabel];
    
    _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_sendButton addTarget:self action:@selector(onSend) forControlEvents:UIControlEventTouchUpInside];
    [_sendButton setFrame:CGRectMake(margin, self.view.height - 35 - 55, self.view.width - margin * 2, 36)];
    [_sendButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"E82550"] size:_sendButton.size cornerRadius:18] forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_sendButton setTitle:@"提交给客服处理" forState:UIControlStateNormal];
    [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [self.view addSubview:_sendButton];
}

- (void)onCoverButtonClicked
{
    ActionSelectView *actionSelectView = [[ActionSelectView alloc] init];
    [actionSelectView setDelegate:self];
    [actionSelectView show];
}

- (void)setContactMe:(BOOL)contactMe
{
    _contactMe = contactMe;
    [_contactButton setSelected:_contactMe];
}

- (void)onContactButtonClicked
{
    self.contactMe = !self.contactMe;
}

- (void)onSend
{
    NSString *contact = [_contactField text];
    NSString *content = [[_textView text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([content length] == 0)
    {
        TNButtonItem *confirmItem = [TNButtonItem itemWithTitle:@"确定" action:nil];
        TNAlertView *alertView = [[TNAlertView alloc] initWithTitle:@"写点要提交的信息吧" buttonItems:@[confirmItem]];
        [alertView show];
        return;
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:kStringFromValue(self.type) forKey:@"type"];
    [params setValue:content forKey:@"content"];
    [params setValue:contact forKey:@"contact"];
    [params setValue:kStringFromValue(self.contactMe) forKey:@"contact_me"];
    
    MBProgressHUD *hud = [MBProgressHUD showMessag:@"正在发送" toView:self.view];
    [[HttpRequestEngine sharedInstance] makeRequestFromUrl:@"setting/feedback" method:REQUEST_POST type:REQUEST_REFRESH withParams:params observer:self completion:^(AFHTTPRequestOperation *operation, TNDataWrapper *responseObject) {
        [hud hide:YES];
        [ProgressHUD showHintText:@"提交客服成功"];
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:2];
    } fail:^(NSString *errMsg) {
        [hud hide:YES];
    }];
}

- (void)dismiss
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string isEqualToString:@"\n"])
    {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = textView.text;
    NSInteger num = [text length];
    if(num > kReportContentMaxNum)
        [textView setText:[text substringToIndex:kReportContentMaxNum]];
    [_numLabel setText:kStringFromValue(kReportContentMaxNum - [textView.text length])];
}

#pragma mark - ActionSelectDelegate
- (NSInteger)numberOfComponentsInPickerView:(ActionSelectView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(ActionSelectView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
    {
        return _sourceArray.count;
    }
    else
    {
        NSInteger firstColomnRow = [pickerView.pickerView selectedRowInComponent:0];
        NSArray *secondArray = _sourceArray[firstColomnRow][@"component"];
        return secondArray.count;
    }
}

- (NSString *)pickerView:(ActionSelectView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *str = nil;
    if(component == 0)
    {
        str =  _sourceArray[row][@"function"];
    }
    else
    {
        NSInteger firstColomnRow = [pickerView.pickerView selectedRowInComponent:0];
        NSArray *secondArray = _sourceArray[firstColomnRow][@"component"];
        if(row < secondArray.count)
            str =  secondArray[row];
    }
    return str;
}

- (void)pickerView:(ActionSelectView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0)
        [pickerView.pickerView reloadComponent:1];
}

- (void)pickerViewFinished:(ActionSelectView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger firstSelectRow = [pickerView.pickerView selectedRowInComponent:0];
    NSInteger secondiSelectRow = [pickerView.pickerView selectedRowInComponent:1];
    NSArray *secondArray = _sourceArray[firstSelectRow][@"component"];
    NSString *secondStr = nil;
    if(secondiSelectRow < secondArray.count)
        secondStr = secondArray[secondiSelectRow];
    [_groupField setText:[NSString stringWithFormat:@"%@ %@",_sourceArray[firstSelectRow][@"function"],secondStr]];
}
@end
