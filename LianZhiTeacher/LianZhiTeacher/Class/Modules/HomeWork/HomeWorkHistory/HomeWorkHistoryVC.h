//
//  HomeWorkHistoryVC.h
//  LianZhiTeacher
//
//  Created by jslsxu on 15/10/31.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import "TNBaseTableViewController.h"
#import "HomeWorkHistoryModel.h"
#import "HomeWorkHistoryCell.h"
@interface HomeWorkHistoryVC : TNBaseTableViewController
@property (nonatomic, copy)void (^completion)(HomeWorkItem *homeWorkItem);
@end
