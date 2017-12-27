//
//  LQGetLocationInfoVC.m
//  LocationInfoFramework
//
//  Created by liuqing on 2017/12/9.
//  Copyright © 2017年 liuqing. All rights reserved.
//

#import "LQGetLocationInfoVC.h"
#import "LQMapPoiTableView.h"
#import "LQSearchResultTableViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <CoreLocation/CoreLocation.h>

/** 屏幕宽 */
#define SCREEN_WIDTH    CGRectGetWidth([UIScreen mainScreen].bounds)
/*-all_load * 屏幕高 */
#define SCREEN_HEIGHT   CGRectGetHeight([UIScreen mainScreen].bounds)
/** 搜索栏高度 */
#define SEARCHBAR_HEIGHT                44.f
/** 导航栏和状态栏高 */
#define NAVANDSTATUSHEIGHT              64.f
/** 搜索结果tableViewcell的高度 */
#define CELL_HEIGHT                     55.f
/** 搜索结果每次展示几个 */
#define CELL_COUNT                      5

@interface LQGetLocationInfoVC () <UISearchResultsUpdating,
                                    CLLocationManagerDelegate,
                                    MAMapViewDelegate,
                                    AMapSearchDelegate,
                                    LQSearchResultTableViewControllerDelegate,
                                    LQMapPoiTableViewDelegate>
/** 授权信息 */
@property(nonatomic,strong)CLLocationManager *locationManager;
/** 搜索控制器 */
@property(nonatomic,strong)UISearchController *searchController;
/** 搜索结果展示 */
@property(nonatomic,strong)LQSearchResultTableViewController *searchResultTableViewController;
/** 地图view 展示地图信息 */
@property(nonatomic,strong)MAMapView *mapView;
/** 地图下面展示的 结果信息 */
@property(nonatomic,strong)LQMapPoiTableView * mapPoiView;
/** 搜索类 */
@property(nonatomic,strong)AMapSearchAPI *searchAPI;
/** 由于点击searchBar要将整体上移,移动self.view不起作用,迫不得已添加一个contentView在view上移动contentView */
@property(nonatomic,strong)UIView * mapContentView;
/** 回到定位点图标 */
@property(nonatomic,strong)UIImageView *centerMaker;
/** 定位按钮 */
@property(nonatomic,strong)UIButton *locationButton;
/** 记录是否是底部table使得地图坐标发生改变 */
@property(nonatomic,assign)BOOL isMapViewRegionChangedFromTableView;
/** 记录第一次定位 */
@property(nonatomic,assign)BOOL isFirstLocated;
/** 记录当前page */
@property(nonatomic,assign)NSInteger searchPage;

@end

@implementation LQGetLocationInfoVC

/**
 初始化方法
 @param apiKey 高德地图注册的apiKey
 @return 示例对象
 */
- (instancetype)initWithApiKey:(NSString *)apiKey{
    if (self = [super init]){
        ///APIkey。设置key，需要绑定对应的bundle id。
        [AMapServices sharedServices].apiKey = apiKey;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AMapServices sharedServices].enableHTTPS = YES;
    
    //设置导航栏
    [self setUpNavigationBar];
    
    [self checkLocationServices];
    ///添加子控件
    [self configUI];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

/**
 设置状态栏
 @return 黑底白色 需要设置 navigationBar.barStyle = UIBarStyleBlack;才会起作用
 */
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

/**
 检查定位服务是否开启
 */
- (void)checkLocationServices{
    ///info.plist字典
    NSArray *infoKeys = [[[NSBundle mainBundle] infoDictionary] allKeys];
    
    if (![infoKeys containsObject:@"NSLocationAlwaysAndWhenInUseUsageDescription"]) {
        NSLog(@"请在info.plist中配置相关key--> Privacy - Location Always and When In Use Usage Description");
    }
    if(![infoKeys containsObject:@"NSLocationWhenInUseUsageDescription"]){
        NSLog(@"请在info.plist中配置相关key--> Privacy - Location When In Use Usage Description");
    }
    ///如果没有授权则申请授权
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}


#pragma mark - 内部控制方法
/**
 设置导航栏
 */
- (void)setUpNavigationBar{
    ///左侧取消按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelClick)];
    [self.navigationItem.leftBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} forState:UIControlStateNormal];
    ///标题
    self.navigationItem.title = @"位置";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    ///右侧 确定按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmClick)];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0.4475560784 green:0.8532296419 blue:0.1005850509 alpha:1.0],NSFontAttributeName:[UIFont boldSystemFontOfSize:15]} forState:UIControlStateNormal];
    [self setUpNavigationItem];
}

/**
 设置导航栏背景色
 */
- (void)setUpNavigationItem{
    [self setNeedsStatusBarAppearanceUpdate];
    if (@available(iOS 11.0,*)) {
        self.navigationItem.searchController = self.searchController;
        UISearchBar *searchBar = self.searchController.searchBar;
        searchBar.tintColor = [UIColor whiteColor];
        searchBar.barTintColor = [UIColor whiteColor];
        UITextField *textfield = [searchBar valueForKey:@"searchField"];
        textfield.textColor = [UIColor blackColor];
        UIView *backgroundView = textfield.subviews.firstObject;
        backgroundView.backgroundColor = [UIColor whiteColor];
        backgroundView.layer.cornerRadius = 10;
        backgroundView.clipsToBounds = TRUE;
    }
    ///确保当用户从 UISearchController 跳转到另一个 view controller 时 search bar 不再显示。
    self.definesPresentationContext = YES;
    //设置导航栏颜色
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;//只有指定了barStyle状态栏才会相应改变
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
}

//取消点击
- (void)cancelClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//确认按钮点击
- (void)confirmClick{
    [self cancelClick];
    ///代理回调
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(getLocationLatitude:longitude:province:city:district:position:) ]) {
        [self.delegate getLocationLatitude:self.mapView.centerCoordinate.latitude
                                 longitude:self.mapView.centerCoordinate.longitude
                                  province:self.mapPoiView.selectedPoi.province
                                      city:self.mapPoiView.selectedPoi.city
                                  district:self.mapPoiView.selectedPoi.district
                                  position:self.mapPoiView.selectedPoi.address];
    }
}

#pragma mark - addSubView

- (void)configUI{
    [self.view addSubview:self.mapContentView];
    [self.mapContentView addSubview:self.mapView];
    [self.mapView addSubview:self.locationButton];
    [self.mapView addSubview:self.centerMaker];
    
    [self.mapContentView addSubview:self.mapPoiView];
    self.searchAPI.delegate = self.mapPoiView;
    
    
    ///绘制中心小蓝点
    [self renderUserCenterPoint];

}

/** 地图回到用户定位点 */
- (void)actionLocation{
    [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
}


- (void)renderUserCenterPoint{
    MAUserLocationRepresentation *r = [[MAUserLocationRepresentation alloc] init];
    [self.mapView updateUserLocationRepresentation:r];
}

#pragma mark lazy load

- (CLLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}


- (UISearchController *)searchController{
    if (!_searchController) {
        _searchController = [[UISearchController alloc]initWithSearchResultsController:self.searchResultTableViewController];
        _searchController.searchResultsUpdater = self;
        _searchController.searchBar.placeholder = @"搜索地点";
        [_searchController.searchBar sizeToFit];
    }
    return _searchController;
}

- (LQSearchResultTableViewController *)searchResultTableViewController{
    if (!_searchResultTableViewController) {
        _searchResultTableViewController = [[LQSearchResultTableViewController alloc]initWithStyle:UITableViewStylePlain];
        _searchResultTableViewController.delegate = self;
        }
    return _searchResultTableViewController;
}

- (UIView *)mapContentView{
    if (!_mapContentView) {
        _mapContentView = [[UIView alloc]initWithFrame:self.view.bounds];
    }
    return _mapContentView;
}

- (MAMapView *)mapView{
    if (!_mapView) {
        _mapView = [[MAMapView alloc]initWithFrame:CGRectMake(0, 52 + NAVANDSTATUSHEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - (52 + NAVANDSTATUSHEIGHT) - CELL_HEIGHT * CELL_COUNT)];
        _mapView.delegate = self;
        _mapView.showsCompass = YES;//显示罗盘
        _mapView.showsScale = YES;//显示缩放比例
        _mapView.scaleOrigin = CGPointMake(10, 10);//比例尺原点位置
        _mapView.showsLabels = YES;
        _mapView.zoomLevel = 15;
        _mapView.showsUserLocation = YES;
    }
    return _mapView;
}

- (LQMapPoiTableView *)mapPoiView{
    if (!_mapPoiView) {
        _mapPoiView = [[LQMapPoiTableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.mapView.frame), SCREEN_WIDTH, CELL_HEIGHT * CELL_COUNT)];
        _mapPoiView.delegate = self;
    }
    return _mapPoiView;
}

- (AMapSearchAPI *)searchAPI{
    if (!_searchAPI) {
        _searchAPI = [[AMapSearchAPI alloc]init];
    }
    return _searchAPI;
}

- (UIImageView *)centerMaker{
    if (!_centerMaker) {
        UIImage *image = [UIImage imageNamed:@"AMap3D.bundle/redPin_lift"];
        _centerMaker = [[UIImageView alloc]initWithImage:image];
        [_centerMaker setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        _centerMaker.center =  CGPointMake(SCREEN_WIDTH / 2, CGRectGetHeight(_mapView.bounds)*0.5f);
    }
    return _centerMaker;
}


- (UIButton *)locationButton{
    if (!_locationButton) {
        _locationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _locationButton.frame = CGRectMake(CGRectGetWidth(self.mapView.bounds)-50, CGRectGetHeight(self.mapView.bounds)-50, 40, 40);
        _locationButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [_locationButton setImage:[UIImage imageNamed:@"AMap3D.bundle/gpsnormal"] forState:UIControlStateNormal];
        [_locationButton setImage:[UIImage imageNamed:@"AMap3D.bundle/gpsselected"] forState:UIControlStateSelected];
        [_locationButton addTarget:self action:@selector(actionLocation) forControlEvents:UIControlEventTouchUpInside];
    }
    return _locationButton;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            NSLog(@"用户还未决定授权定位服务!");
            break;
        case kCLAuthorizationStatusRestricted:
            NSLog(@"定位服务受限!");
            break;
        case kCLAuthorizationStatusDenied:
            if([CLLocationManager locationServicesEnabled]){
                NSLog(@"定位服务授权被用户拒绝!");
            }
            else{
                NSLog(@"定位服务未开启!");
            }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"定位服务始终开启!");
            break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            NSLog(@"定位服务使用期间开启!");
            break;
        default:
            break;
    }
}


#pragma mark - UISearchViewControllerDelegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    
    self.searchResultTableViewController.searchKeyword = searchController.searchBar.text;
    
    /// 当searchBar活跃时  将整体视图上移 46
    if (self.searchController.active) {
        [UIView animateWithDuration:0.25 animations:^{
            self.mapContentView.transform = CGAffineTransformMakeTranslation(0, -46);
        }];
    }else{
        ///不活跃状态恢复原状
        [UIView animateWithDuration:0.25 animations:^{
            self.mapContentView.transform = CGAffineTransformIdentity;
        }];
    }
}

#pragma mark - LQSearchResultManagerDelegate
///选中了搜索结果的某一行
- (void)didSelectedLocationWithLocation:(AMapPOI *)poi{
    self.searchController.active = NO;
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(poi.location.latitude,poi.location.longitude) animated:NO];
}

#pragma mark - MapPoiTableViewDelegate
///下拉刷新
- (void)pullRefresh{
    self.searchPage = 1;
    [self searchPoiByAMapGeoPoint];
}

// 加载更多列表数据
- (void)loadMore{
    self.searchPage++;
    [self searchPoiByAMapGeoPoint];
}

// 将地图中心移到所选的POI位置上
- (void)setMapCenterWithPOI:(AMapPOI *)point{
    self.isMapViewRegionChangedFromTableView = YES;
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(point.location.latitude, point.location.longitude);
    [self.mapView setCenterCoordinate:location animated:YES];
    [self checkThePinIsInCurrentLocationCenter];
}

// 设置当前位置所在城市
- (void)setCurrentCity:(NSString *)city{
    self.searchResultTableViewController.city = city;
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    // 首次定位
    if (updatingLocation && !self.isFirstLocated) {
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude)];
        
        [self searchReGeocodeWithAMapGeoPoint];
        
        [self searchPoiByAMapGeoPoint];
        
        self.locationButton.selected = YES;
        
        self.isFirstLocated = YES;
    }
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    
    if (!self.isMapViewRegionChangedFromTableView && self.isFirstLocated) {
       
        [self searchReGeocodeWithAMapGeoPoint];

        [self searchPoiByAMapGeoPoint];
        // 范围移动时当前页面数重置
        self.searchPage = 1;
        [self checkThePinIsInCurrentLocationCenter];
        
        ///大头针动画
        [UIView animateWithDuration:0.25 animations:^{
            self.centerMaker.transform = CGAffineTransformMakeTranslation(0, -20);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25 animations:^{
                self.centerMaker.transform = CGAffineTransformIdentity;
            }];
        }];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mapPoiView scrollToTop];
        });
        
    
    }
    self.isMapViewRegionChangedFromTableView = NO;
}

#pragma mark locationButton 的选中状态改变 根据 大头针是否在定位点

- (void)checkThePinIsInCurrentLocationCenter{
    NSString *mapViewLatitude = [NSString stringWithFormat:@"%0.3f",self.mapView.userLocation.location.coordinate.latitude];
    NSString *mapViewLongitude = [NSString stringWithFormat:@"%0.3f",self.mapView.userLocation.location.coordinate.longitude];
    NSString *pointLatitude = [NSString stringWithFormat:@"%0.3f",self.mapView.centerCoordinate.latitude];
    NSString *pointLongitude = [NSString stringWithFormat:@"%0.3f",self.mapView.centerCoordinate.longitude];
    
    if ([mapViewLatitude isEqualToString:pointLatitude] && [mapViewLongitude isEqualToString:pointLongitude]) {
        self.locationButton.selected = YES;
    }
    else{
        self.locationButton.selected = NO;
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        return nil;
    }
    return nil;
}

// 搜索逆向地理编码-AMapGeoPoint
- (void)searchReGeocodeWithAMapGeoPoint
{
    AMapGeoPoint *location = [AMapGeoPoint locationWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = location;
    // 返回扩展信息
    regeo.requireExtension = YES;
    [self.searchAPI AMapReGoecodeSearch:regeo];
}

// 搜索中心点坐标周围的POI-AMapGeoPoint
- (void)searchPoiByAMapGeoPoint
{
     AMapGeoPoint *location = [AMapGeoPoint locationWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = location;
    // 搜索半径
    request.radius = 1000;
    // 搜索结果排序
    request.sortrule = 1;
    // 当前页数
    request.page = self.searchPage;
    [self.searchAPI AMapPOIAroundSearch:request];
}

@end


