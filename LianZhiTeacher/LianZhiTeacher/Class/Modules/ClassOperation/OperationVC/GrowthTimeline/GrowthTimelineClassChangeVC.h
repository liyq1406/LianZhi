//
//  GrowthTimelineClassChangeVC.h
//  LianZhiTeacher
//
//  Created by jslsxu on 15/9/9.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import "TNBaseViewController.h"
#import "NotificationTargetSelectVC.h"

@interface GrowthTimelineClassChangeVC : TNBaseViewController<UITableViewDataSource, UITableViewDelegate>
{
    UITableView*        _tableView;
}
@property (nonatomic, strong)NSMutableDictionary *record;
@end
