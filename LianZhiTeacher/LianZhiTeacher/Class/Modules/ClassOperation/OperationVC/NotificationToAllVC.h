//
//  NotificationToAllVC.h
//  LianZhiTeacher
//
//  Created by jslsxu on 15/1/30.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import "TNBaseViewController.h"

@interface NotificationItem : TNModelItem
@property (nonatomic, copy)NSString *notificationID;
@property (nonatomic, copy)NSString *words;
@property (nonatomic, assign)NSInteger notificationType;
@property (nonatomic, copy)NSString *ctime;
@end

@interface NotificationModel : TNListModel
@property (nonatomic, assign)NSInteger total;
@end

@interface NotificationCell : TNTableViewCell
{
    UIView* _sepLine;
}
@end

@interface NotificationToAllVC : TNBaseTableViewController
{
    
}
@end