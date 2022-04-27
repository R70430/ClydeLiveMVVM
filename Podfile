# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'ClydeLiveMVVM' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

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
  post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
      config.build_settings.delete('CODE_SIGNING_ALLOWED')
      config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
  end
  target 'ClydeLiveMVVMUITests' do
    # Pods for testing
  end

end
