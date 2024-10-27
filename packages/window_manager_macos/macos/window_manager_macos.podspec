#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint window_manager.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'window_manager_macos'
  s.version          = '0.2.0'
  s.summary          = 'macOS implementation of the window_manager plugin.'
  s.description      = <<-DESC
macOS implementation of the window_manager plugin.
                       DESC
  s.homepage         = 'https://leanflutter.dev'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'LiJianying' => 'lijy91@foxmail.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
