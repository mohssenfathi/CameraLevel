#
# Be sure to run `pod lib lint CameraLevel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "CameraLevel"
  s.version          = "0.1.0"
  s.summary          = "CameraLevel is a quick drop in level, similar to a DSLR's digital level, that can be overlayed on a camera preview layer."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
  CameraLevel uses the devices accelerometer to calculate the current pitch and roll of the device. It is a UIView subclass that can be overlayed on an AV preview layer. The level is intended to be used in photography applications, similar to the levels found on common DSLRs.
                       DESC

  s.homepage         = "https://github.com/mohssenfathi/CameraLevel"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Mohssen Fathi" => "mmohssenfathi@gmail.com" }
  s.source           = { :git => "https://github.com/mohssenfathi/CameraLevel.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'CameraLevel' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
