

Pod::Spec.new do |s|
  s.name             = 'GZIMPaySmartPOS'
  s.version          = '0.0.1'
  s.summary          = 'GZIMPaySmartPOS for netpos'


  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/wanghuizhou21@163.com/GZIMPaySmartPOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wanghuizhou21@163.com' => 'wanghuizhou@guazi.com' }
  s.source           = { :git => 'https://github.com/wanghuizhou21@163.com/GZIMPaySmartPOS.git', :tag => s.version.to_s }


  s.ios.deployment_target = '8.0'

  s.source_files = 'GZIMPaySmartPOS/Classes/**/*'
  
   s.resource_bundles = {
     'GZIMPaySmartPOS' => ['GZIMPaySmartPOS/Assets/*']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
   s.dependency 'SocketRocket'
end
