//
//  LQSearchResultTableViewController.h
//  LocationInfoFramework
//
//  Created by liuqing on 2017/12/14.
//  Copyright © 2017年 liuqing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AMapPOI;
@protocol LQSearchResultTableViewControllerDelegate <NSObject>
/**
 选中某一行搜索结果
 @param poi 选中的结果
 */
- (void)didSelectedLocationWithLocation:(AMapPOI *)poi;

@end

@interface LQSearchResultTableViewController : UITableViewController
/** 代理 */
@property(nonatomic,weak)id<LQSearchResultTableViewControllerDelegate>delegate;
/** 搜索关键字 */
@property(nonatomic,copy)NSString * searchKeyword;
/** 定位城市 */
@property(nonatomic,copy)NSString * city;

@end
