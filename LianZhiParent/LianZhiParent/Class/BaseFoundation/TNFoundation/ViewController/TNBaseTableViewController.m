//
//  TNBaseTableViewController.m
//  TNFoundation
//
//  Created by jslsxu on 14-9-6.
//  Copyright (c) 2014年 jslsxu. All rights reserved.
//

#import "TNBaseTableViewController.h"
#import <objc/message.h>

#define CELL_HEIGHT_SEL     @"cellHeight:cellWidth:"
#define FOOTERVIEW_HEIGHT   50.0
#define FOOT_MORE_OFFSET    5

@interface TNBaseTableViewController ()
@property (nonatomic, copy)NSString *cellName;
@property (nonatomic, copy)NSString *modelName;
@end

@implementation TNBaseTableViewController

- (id)init
{
    self = [super init];
    if(self)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        [self setAutomaticallyAdjustsScrollViewInsets:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:[self tableViewStyle]];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [self.view addSubview:_tableView];
}

- (UITableViewStyle)tableViewStyle
{
    return UITableViewStylePlain;
}

- (void)bindTableCell:(NSString *)cellName tableModel:(NSString *)modelName
{
    self.cellName = cellName;
    self.modelName = modelName;
    _tableViewModel = [[NSClassFromString(modelName) alloc] init];
    if(![_tableViewModel isKindOfClass:[TNListModel class]])
        return;
    [self loadCache];
}


- (void)loadCache
{
    if([self supportCache])//支持缓存，先出缓存中读取数据
    {
        id responseObject = [NSDictionary dictionaryWithContentsOfFile:[self cacheFilePath]];
        if(responseObject)
        {
            [_tableViewModel parseData:[TNDataWrapper dataWrapperWithObject:responseObject] type:REQUEST_REFRESH];
            [self.tableView reloadData];
            if([self respondsToSelector:@selector(TNBaseTableViewControllerRequestSuccess)])
                [self TNBaseTableViewControllerRequestSuccess];
        }
    }
}

- (void)setSupportPullDown:(BOOL)supportPullDown
{
    _supportPullDown = supportPullDown;
    if(_supportPullDown)
    {
        if(!_refreshHeaderView)
        {
            _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.height, self.tableView.width, self.tableView.height)];
            _refreshHeaderView.delegate = self;
        }
        if(_refreshHeaderView.superview == nil)
            [self.tableView addSubview:_refreshHeaderView];
    }
    else
    {
        [_refreshHeaderView removeFromSuperview];
    }
}

- (void)setSupportPullUp:(BOOL)supportPullUp
{
    _supportPullUp = supportPullUp;
    if(_supportPullUp)
    {
        _getMoreCell = [[TNGetMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"RefreshFooter"];
    }
}

- (void)showEmptyLabel:(BOOL)show
{
    if(_emptyLabel == nil)
    {
        _emptyLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
        [_emptyLabel setBackgroundColor:[UIColor clearColor]];
        [_emptyLabel setTextColor:[UIColor colorWithHexString:@"999999"]];
        [_emptyLabel setFont:[UIFont systemFontOfSize:14]];
        [_emptyLabel setText:@"还没有任何内容哦"];
        [_emptyLabel sizeToFit];
        [self.tableView addSubview:_emptyLabel];
    }
    [self.tableView bringSubviewToFront:_emptyLabel];
    [_emptyLabel setHidden:!show];
    [_emptyLabel setCenter:CGPointMake(self.tableView.width / 2, self.tableView.height / 2 + 30)];
}

- (void)requestData:(REQUEST_TYPE)requestType
{
    if(!_isLoading)
    {
        HttpRequestTask *task = [self makeRequestTaskWithType:requestType];
        if(task)
        {
            _isLoading = YES;
            __weak typeof(self) wself = self;
            AFHTTPRequestOperation *operation = [[HttpRequestEngine sharedInstance] makeRequestFromUrl:task.requestUrl method:task.requestMethod type:requestType withParams:task.params observer:task.observer completion:^(AFHTTPRequestOperation *operation, TNDataWrapper * responseObject) {
                [wself onRequestSuccess:operation responseData:responseObject];
            } fail:^(NSString *errMsg) {
                [wself onRequestFail:errMsg];
            }];
            if(operation)
            {
                if([self respondsToSelector:@selector(TNBaseTableViewControllerRequestStart)])
                    [self TNBaseTableViewControllerRequestStart];
                //请求开始
                if(requestType == REQUEST_GETMORE)
                    [_getMoreCell startLoading];
            }

        }
        else
        {
            _isLoading = NO;
            [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
            [_getMoreCell stopLoading];
        }
    }
}

- (void)onRequestSuccess:(AFHTTPRequestOperation *)operation responseData:(TNDataWrapper *)responseData
{
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    [_getMoreCell stopLoading];
    [_tableViewModel parseData:responseData type:operation.requestType];
    if(self.shouldShowEmptyHint)
        [self showEmptyLabel:_tableViewModel.modelItemArray.count == 0];
    if([self supportCache] && operation.requestType == REQUEST_REFRESH)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [responseData.data writeToFile:[self cacheFilePath] atomically:YES];
        });
    }
    if([self needReload])
        [self.tableView reloadData];
    _isLoading = NO;
    if([self respondsToSelector:@selector(TNBaseTableViewControllerRequestSuccess)])
        [self TNBaseTableViewControllerRequestSuccess];
}

- (void)onRequestFail:(NSString *)errMsg
{
    if(![self hideErrorAlert])
        [ProgressHUD showHintText:errMsg];
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
    [_getMoreCell stopLoading];
    _isLoading = NO;
    if([self respondsToSelector:@selector(TNBaseTableViewControllerRequestFailedWithError:)])
        [self TNBaseTableViewControllerRequestFailedWithError:errMsg];
}

- (void)cancelRequest
{
    [[HttpRequestEngine sharedInstance] cancelTaskByObserver:self];
}

- (HttpRequestTask *)makeRequestTaskWithType:(REQUEST_TYPE)requestType
{
    return nil;//子类覆盖
}

- (BOOL)hideErrorAlert
{
    return NO;
}

- (BOOL)needReload
{
    return YES;
}

#pragma mark - 
#pragma mark UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger count = [_tableViewModel numOfSections];
    if([_tableViewModel hasMoreData] && _supportPullUp)
        count ++;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numOfSections = [self numberOfSectionsInTableView:tableView];
    if([_tableViewModel hasMoreData] && _supportPullUp && section == numOfSections - 1)
        return 1;
    else
    {
        return [_tableViewModel numOfRowsInSection:section];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_tableViewModel hasMoreData] && indexPath.section == [self numberOfSectionsInTableView:tableView] - 1 && _supportPullUp)
    {
        return FOOTERVIEW_HEIGHT;
    }
    
    TNModelItem *item = [_tableViewModel itemForIndexPath:indexPath];
    NSNumber* (*action)(id, SEL, id,NSInteger) = (NSNumber* (*)(id, SEL,id, NSInteger)) objc_msgSend;
    NSNumber* height = action([NSClassFromString(self.cellName) class], NSSelectorFromString(CELL_HEIGHT_SEL), item, (int) _tableView.frame.size.width);
    return [height floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_tableViewModel hasMoreData] && _supportPullUp && indexPath.section == [self numberOfSectionsInTableView:tableView] - 1)
    {
        return _getMoreCell;
    }
    TNTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellName];
    if (!cell) {
        cell = [[NSClassFromString(self.cellName) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:self.cellName];
        
        [cell setWidth:tableView.frame.size.width];
    }
    TNModelItem *item = [_tableViewModel itemForIndexPath:indexPath];
    [cell setData:item];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_tableViewModel hasMoreData] && _supportPullUp && indexPath.section == [self numberOfSectionsInTableView:tableView] - 1)
        [self requestData:REQUEST_GETMORE];
    else
    {
        if([self respondsToSelector:@selector(TNBaseTableViewControllerItemSelected:atIndex:)])
            [self TNBaseTableViewControllerItemSelected:[_tableViewModel itemForIndexPath:indexPath] atIndex:indexPath];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    NSInteger bottomOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    bottomOffset = (bottomOffset > 0) ? bottomOffset : 0;
    if([scrollView contentOffset].y >= (bottomOffset + FOOT_MORE_OFFSET))
    {
        if(!_isLoading && _supportPullUp && _getMoreCell.superview && [_tableViewModel hasMoreData]) {
            [self requestData:REQUEST_GETMORE];
        }
    }
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    
    [self requestData:REQUEST_REFRESH];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    
    return _isLoading; // should return if data source model is reloading
    
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

#pragma - cache

- (BOOL)supportCache
{
    return NO;
}

- (NSString *)cacheFilePath
{
    NSString *cacheName = [self cacheFileName];
    if(cacheName)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        NSString *commonCacheRoot = [HttpRequestEngine sharedInstance].commonCacheRoot;
        NSString *filePath = docDir;
        filePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",commonCacheRoot,cacheName]];
        return filePath;
    }
    return nil;
}

- (NSString *)cacheFileName
{
    return nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self cancelRequest];
}
@end
