//
//  ClassZoneVC.h
//  LianZhiParent
//
//  Created by jslsxu on 14/12/17.
//  Copyright (c) 2014年 jslsxu. All rights reserved.
//

#import "TNBaseTableViewController.h"
#import "ClassZoneClassSwitchView.h"
#import "ClassAppVC.h"
#import "ClassZoneItemCell.h"
#import "PublishArticleVC.h"
#import "PublishAudioVC.h"
#import "PublishPhotoVC.h"
#import "PublishNewspaperVC.h"
#import "ClassZoneManager.h"
#import "ReplyBox.h"
#import "ActionView.h"
#import "StatusManager.h"
extern NSString *const kPublishPhotoItemFinishedNotification;
extern NSString *const kPublishPhotoItemKey;

@interface NewMessageIndicator : UIView
{
    AvatarView* _avatarView;
    UILabel*    _indicatorLabel;
    UIButton*   _coverButton;
}
@property (nonatomic, strong)TimelineCommentItem *commentItem;
@property (nonatomic, copy)void (^clickAction)();
@end

@protocol ClassZoneHeaderDelegate <NSObject>
- (void)classZoneAppClicked;
- (void)classZoneAlbumClicked;
- (void)classNewspaperClicked;
@end
@interface ClassZoneHeaderView : UIView
{
    UIImageView*            _imageView;
    UIImageView*            _newpaperImageView;
    UILabel*                _contentLabel;
    UIImageView*            _brashImage;
    UIView*                 _bottomView;
     NewMessageIndicator*    _msgIndicator;
}
@property (nonatomic, strong)ClassInfo *classInfo;
@property (nonatomic, copy)NSString *newsPaper;
@property (nonatomic, weak)id<ClassZoneHeaderDelegate> delegate;
@property (nonatomic, strong)TimelineCommentItem *commentItem;
@end

@interface ClassZoneVC : TNBaseTableViewController<ClassZoneHeaderDelegate, PublishZoneItemDelegate, ReplyBoxDelegate, ClassZoneItemCellDelegate>
{
    ClassZoneHeaderView*            _headerView;
    UIView*                      _publishToolBar;
    NSMutableArray*                 _buttonItems;
    ReplyBox*                       _replyBox;
}
@property (nonatomic, strong)ClassInfo *classInfo;
@end
