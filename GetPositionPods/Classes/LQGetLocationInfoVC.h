//
//  LQGetLocationInfoVC.h
//  LocationInfoFramework
//
//  Created by liuqing on 2017/12/9.
//  Copyright © 2017年 liuqing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LQGetLocationInfoVCDelegate <NSObject>
@required;
/**
 获取地理位置信息
 @param latitude 经度
 @param longitude 纬度
 @param province 省
 @param city 市
 @param district 行政区
 @param position 详细位置信息
 */
- (void)getLocationLatitude:(double)latitude
                  longitude:(double)longitude
                   province:(NSString *)province
                       city:(NSString *)city
                   district:(NSString *)district
                   position:(NSString *)position;

@end

@interface LQGetLocationInfoVC : UIViewController
/** 代理 */
@property(nonatomic,weak)id<LQGetLocationInfoVCDelegate> delegate;
/**
 高德地图注册
 @param apiKey 高德地图开发者网站申请的key
 @return 对象
 */
- (instancetype)initWithApiKey:(NSString *)apiKey;

@end
