//
//  LQMapPoiTableView.h
//  LocationInfoFramework
//
//  Created by liuqing on 2017/12/12.
//  Copyright © 2017年 liuqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@protocol LQMapPoiTableViewDelegate <NSObject>
///下拉刷新
- (void)pullRefresh;
///加载更多 结果
- (void)loadMore;
// 将地图中心移到所选的POI位置上
- (void)setMapCenterWithPOI:(AMapPOI *)point;
// 设置当前位置所在城市
- (void)setCurrentCity:(NSString *)city;
@end

@interface LQMapPoiTableView : UIView<AMapSearchDelegate>

@property(nonatomic,strong)AMapPOI *selectedPoi;
///代理
@property(nonatomic,weak)id <LQMapPoiTableViewDelegate>delegate;

- (void)scrollToTop;
@end
