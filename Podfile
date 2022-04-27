# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ClydeLiveMVVM' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
    # some older pods don't support some architectures, anything over iOS 11 resolves that
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end

  # Pods for ClydeLiveMVVM
  pod 'Firebase/Auth'
  pod 'Firebase/Storage'
  pod 'lottie-ios'
  pod 'SDWebImage', '~> 5.0'
  pod 'RxSwift'
  pod 'RxCocoa'

  target 'ClydeLiveMVVMTests' do
    inherit! :search_paths
    # Pods for testing
  end
 
  target 'ClydeLiveMVVMUITests' do
    # Pods for testing
  end

end
