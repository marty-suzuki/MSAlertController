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
  s.version          = "0.1.1"
  s.summary          = "MSAlertController is possible you to use AlertController in iOS7."

  s.homepage         = "https://github.com/szk-atmosphere/MSAlertController"
  s.license          = 'MIT'
  s.author           = { "Taiki Suzuki" => "s1180183@gmail.com" }
  s.source           = { :git => "https://github.com/szk-atmosphere/MSAlertController.git", :tag => "v0.1.1" }
  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'MSAlertController/*.{h,m}'
  s.resources    = 'MSAlertController/*.xib'
  s.frameworks = 'UIKit', 'QuartzCore'
end
