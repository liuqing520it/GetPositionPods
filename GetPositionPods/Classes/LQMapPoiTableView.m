//
//  LQMapPoiTableView.m
//  LocationInfoFramework
//
//  Created by liuqing on 2017/12/12.
//  Copyright © 2017年 liuqing. All rights reserved.
//

#import "LQMapPoiTableView.h"
#import "UIScrollView+SVInfiniteScrolling.h"

@interface LQMapPoiTableView()<UITableViewDelegate,UITableViewDataSource>
/** TableView */
@property(nonatomic,strong)UITableView *tableView;
/** 下拉刷新控件 */
@property(nonatomic,strong)UIRefreshControl * refreshControl;
/** 数据源 */
@property(nonatomic,strong)NSMutableArray * dataSource;
/** 选中的那一行IndexPath */
@property(nonatomic,strong)NSIndexPath * selectedIndexPath;

@property(nonatomic,assign)BOOL isFromMoreLoadRequest;

@end

@implementation LQMapPoiTableView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        if (@available(iOS 11.0, *)) {
            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            
            }
        [self addSubview:self.tableView];
    }
    return self;
}

#pragma mark - 外部控制方法
///回到顶部
- (void)scrollToTop{
    [self.tableView setContentOffset:CGPointZero animated:YES];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

#pragma mark - 内部控制方法

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.refreshControl = self.refreshControl;
        __weak typeof (self)weakSelf = self;
        [_tableView addInfiniteScrollingWithActionHandler:^{
            [weakSelf loadMoreData];
        }];
    }
    return _tableView;
}

- (UIRefreshControl *)refreshControl{
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc]init];
        [_refreshControl addTarget:self action:@selector(pullRefreshData) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}


- (AMapPOI *)selectedPoi{
    if (!_selectedPoi) {
        _selectedPoi = [[AMapPOI alloc]init];
    }
    return _selectedPoi;
}

- (NSMutableArray *) dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        AMapPOI *point = [[AMapPOI alloc] init];
        [_dataSource addObject:point];
    }
    return _dataSource;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NSStringFromClass([UITableViewCell class])];
    }
    AMapPOI *point = self.dataSource[indexPath.row];
    cell.textLabel.text = point.name;
    cell.textLabel.textColor = [UIColor blackColor];
    if (indexPath.row == 0) {
        cell.textLabel.frame = cell.frame;
        cell.textLabel.font = [UIFont systemFontOfSize:20.f];
        cell.detailTextLabel.text = @"";
    }
    else {
        cell.textLabel.font = [UIFont systemFontOfSize:16.f];
        cell.detailTextLabel.text = point.address;
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    cell.accessoryType = (self.selectedIndexPath.row == indexPath.row) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 单选打勾
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger newRow = indexPath.row;
    NSInteger oldRow = self.selectedIndexPath != nil ? self.selectedIndexPath.row : -1;
    if (newRow != oldRow) {
        UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
        UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:_selectedIndexPath];
        lastCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    self.selectedIndexPath = indexPath;
    
    // 将地图中心移到选中的位置
    self.selectedPoi = self.dataSource[indexPath.row];
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(setMapCenterWithPOI:)]) {
        
        [self.delegate setMapCenterWithPOI:self.selectedPoi];
    }
}

#pragma mark - AMapSearchDelegate

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if (response.regeocode != nil) {
        self.selectedPoi.province = response.regeocode.addressComponent.province;
        self.selectedPoi.city = response.regeocode.addressComponent.city;
        self.selectedPoi.district = response.regeocode.addressComponent.district;
        // 去掉逆地理编码结果的省份和城市
        NSString *address = response.regeocode.formattedAddress;
        AMapAddressComponent *component = response.regeocode.addressComponent;
        address = [address stringByReplacingOccurrencesOfString:component.province withString:@""];
        address = [address stringByReplacingOccurrencesOfString:component.city withString:@""];
        // 将逆地理编码结果保存到数组第一个位置，并作为选中的POI点
        self.selectedPoi.name = address;
        self.selectedPoi.address = address;
        self.selectedPoi.location = request.location;
        
        [self.dataSource setObject:self.selectedPoi atIndexedSubscript:0];
        // 刷新TableView第一行数据
        NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[reloadIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        NSLog(@"_selectedPoi.name:%@",_selectedPoi.name);
        // 刷新后TableView返回顶部
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
        
        NSString *city = response.regeocode.addressComponent.city;
        [self.delegate setCurrentCity:city];
    }
}


- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    // 刷新POI后默认第一行为打勾状态
    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    // 判断搜索结果是否来自于上拉加载
    if (_isFromMoreLoadRequest) {
        _isFromMoreLoadRequest = NO;
        ///加拉加载停止
        [self.tableView.infiniteScrollingView stopAnimating];
    }
    else{
        //保留数组第一行数据
        if (self.dataSource.count > 1) {
            [self.dataSource removeObjectsInRange:NSMakeRange(1, self.dataSource.count-1)];
        }
        ///下拉刷新停止
        [self.tableView.refreshControl endRefreshing];
    }
    
  
    // 添加数据并刷新TableView
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        [self.dataSource addObject:obj];
    }];
    
    int i = 0;
    for (AMapPOI * obj in self.dataSource) {
        AMapPOI *poi = [self.dataSource firstObject];
        if (i != 0) {
            obj.province = poi.province;
            obj.city = poi.city;
            obj.district = poi.district;
        }
        i++;
    }
    
    [self.tableView reloadData];
    
  
}

///下拉刷新
- (void)pullRefreshData{
    if ([self.delegate respondsToSelector:@selector(pullRefresh)]) {
        [self.delegate pullRefresh];
    }
}

///上拉加载更多
- (void)loadMoreData
{
    if ([self.delegate respondsToSelector:@selector(loadMore)]) {
        [self.delegate loadMore];
        _isFromMoreLoadRequest = YES;
    }
}
@end
