//
//  FeedItemDetailVC.h
//  LianZhiTeacher
//
//  Created by jslsxu on 15/9/29.
//  Copyright (c) 2015年 jslsxu. All rights reserved.
//

#import "TNBaseTableViewController.h"
#import "ClassZoneModel.h"
#import "PraiseListView.h"

@interface FeedItemDetailHeaderView : UIView<UICollectionViewDataSource, UICollectionViewDelegate>
{
    AvatarView* _avatar;
    UILabel*    _nameLabel;
    UILabel*    _timeLabel;
    UILabel*    _addressLabel;
    UIButton*   _addressButton;
    UIButton*   _deleteButon;
    UILabel*    _contentLabel;
    MessageVoiceButton* _voiceButton;
    UILabel*    _spanLabel;
    UICollectionView*   _collectionView;
}
@property (nonatomic, strong)ClassZoneItem *zoneItem;
@property (nonatomic, copy)void (^deleteCallBack)();
@end

@interface FeedItemDetailVC : TNBaseViewController
{
    FeedItemDetailHeaderView*   _headerView;
    PraiseListView*             _praiseView;
    UITableView*                _tableView;
    UIToolbar*                  _toolBar;
    NSMutableArray*             _buttonItems;
    ReplyBox*                   _replyBox;
}
@property (nonatomic, copy)NSString *classId;
@property (nonatomic, strong)ClassZoneItem *zoneItem;
@property (nonatomic, copy)void (^deleteCallBack)();
@end
