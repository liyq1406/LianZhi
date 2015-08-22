//
//  PasswordConfirmVC.m
//  LianZhiParent
//
//  Created by jslsxu on 15/8/18.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import "PasswordConfirmVC.h"

@interface PasswordConfirmVC ()

@end

@implementation PasswordConfirmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"重置密码";
    _passwordField = [[LZTextField alloc] initWithFrame:CGRectMake(10, 20, self.view.width - 10 * 2, 45)];
    [_passwordField setFont:[UIFont systemFontOfSize:16]];
    [_passwordField setTextColor:kCommonParentTintColor];
    [_passwordField setReturnKeyType:UIReturnKeyDone];
    [_passwordField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_passwordField setSecureTextEntry:YES];
    [_passwordField setPlaceholder:@"请输入密码"];
    [self.view addSubview:_passwordField];
    
    _confirmField = [[LZTextField alloc] initWithFrame:CGRectMake(10, _passwordField.bottom + 15, self.view.width - 10 * 2, 45)];
    [_confirmField setFont:[UIFont systemFontOfSize:16]];
    [_confirmField setTextColor:kCommonParentTintColor];
    [_confirmField setReturnKeyType:UIReturnKeyDone];
    [_confirmField setKeyboardType:UIKeyboardTypeDecimalPad];
    [_confirmField setSecureTextEntry:YES];
    [_confirmField setPlaceholder:@"确认密码"];
    [self.view addSubview:_confirmField];
    
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton setFrame:CGRectMake(10, _confirmField.bottom + 15, self.view.width - 10 * 2, 45)];
    [finishButton addTarget:self action:@selector(onFinishClicked) forControlEvents:UIControlEventTouchUpInside];
    [finishButton setBackgroundImage:[[UIImage imageWithColor:kCommonParentTintColor size:CGSizeMake(30, 30) cornerRadius:5] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
    [finishButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [finishButton setTitle:@"完成" forState:UIControlStateNormal];
    [finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:finishButton];
}

- (void)onFinishClicked
{
    
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
