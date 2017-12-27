

Pod::Spec.new do |s|
  s.name             = 'GetPositionPods'
  s.version          = '0.1.0'
  s.summary          = 'GetPositionPods.'

  s.description      = <<-DESC
TODO: GetPositionPods.获取当前位置信息
                       DESC

  s.homepage         = 'https://github.com/liuqing520it/GetPositionPods'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'liuqing520it' => '330663384@qq.com' }
  s.source           = { :git => 'https://github.com/liuqing520it/GetPositionPods.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'GetPositionPods/Classes/**/*'
  
  # s.resource_bundles = {
  #   'GetPositionPods' => ['GetPositionPods/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'AMap3DMap'
  s.dependency 'AMapSearch'
end
