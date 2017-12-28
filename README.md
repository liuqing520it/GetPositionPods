# GetPositionPods

[![CI Status](http://img.shields.io/travis/ios330663384/GetPositionPods.svg?style=flat)](https://travis-ci.org/ios330663384/GetPositionPods)
[![Version](https://img.shields.io/cocoapods/v/GetPositionPods.svg?style=flat)](http://cocoapods.org/pods/GetPositionPods)
[![License](https://img.shields.io/cocoapods/l/GetPositionPods.svg?style=flat)](http://cocoapods.org/pods/GetPositionPods)
[![Platform](https://img.shields.io/cocoapods/p/GetPositionPods.svg?style=flat)](http://cocoapods.org/pods/GetPositionPods)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

![image](https://github.com/liuqing520it/GetLocation/raw/master/images/getposition.gif)


## Requirements
* info.plist must add some keys : "Privacy - Location When In Use Usage Description" and "Privacy - Location Always and When In Use Usage Description"


## Installation

GetPositionPods is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'GetPositionPods'
```
## Usage

### Import header and follow deleagate
```ObjC
#import <LQGetLocationInfoVC.h>
@interface ViewController ()<LQGetLocationInfoVCDelegate>
```

### Implement the proxy method
```ObjC
/**
present选择地址的控制器
*/
- (void)presentVC{
    ///这里的ApiKey 是高德开放平台申请的,需要绑定对应的bundle id;具体申请流程请参考'高德开放平台'
    LQGetLocationInfoVC *locationVC = [[LQGetLocationInfoVC alloc]initWithApiKey:@"491fb90b01e62xxx9cf80ec44a14bd03d"];
    locationVC.delegate = self;
    [self presentViewController:[[UINavigationController alloc]initWithRootViewController:locationVC] animated:YES completion:nil];
}

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
                   position:(NSString *)position{
    //这里只是将结果alert出来,方便验证
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"位置信息" message:[NSString stringWithFormat:@"经度:%f;\n纬度:%f;\n%@-%@-%@-%@",latitude,longitude,province,city,district,position] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
```

## Author

liuqing, 330663384@qq.com

## License

GetPositionPods is available under the MIT license. See the LICENSE file for more info.
