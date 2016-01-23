#
# Be sure to run `pod lib lint MSAlertController.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MSAlertController"
  s.version          = "2.0.0"
  s.summary          = "MSAlertController is possible you to use AlertController in iOS7."

  s.homepage         = "https://github.com/szk-atmosphere/MSAlertController"
  s.license          = 'MIT'
  s.author           = { "Taiki Suzuki" => "s1180183@gmail.com" }
  s.source           = { :git => "https://github.com/szk-atmosphere/MSAlertController.git", :tag => s.version.to_s }
  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'MSAlertController/*.{h,m,swift}'
  s.resource_bundles = {
    'MSAlertController' => ['MSAlertController/*.xib']
  }
  s.frameworks = 'UIKit', 'QuartzCore'
  s.dependency 'MisterFusion'
  s.dependency 'SABlurImageView'
end
