#
#  Be sure to run `pod spec lint CYLRefreshPageManager.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

s.name         = "CYLRefreshPageManager"
s.version      = "1.0.0"
s.summary      = "Simple one line code."
s.homepage     = "https://github.com/nicecyl/CYLRefreshPageManager"
s.license      = "MIT"
s.author       = { "nicecyl" => "416793887@qq.com" }
s.platform     = :ios, "9.0"
s.source       = { :git => "https://github.com/nicecyl/CYLRefreshPageManager.git", :tag => s.version }
s.source_files  = "CYLRefreshPageManager", "CYLRefreshPageManager/*.{h,m}"
s.framework  = "UIKit"
s.requires_arc = true
s.dependency 'MJRefresh'

end
