#
# Be sure to run `pod lib lint FSPhotoBrowser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "FSPhotoBrowser"
  s.version          = "0.1.10"
  s.summary          = "Facebook style photo browser"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = "Facebook Style Photo Browser"

  s.homepage         = "https://github.com/DevDivinity/FSPhotoBrowser"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "DevDivinity" => "DevDivinity" }
  s.source           = { :git => "https://github.com/DevDivinity/FSPhotoBrowser.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resources     =  'Pod/Assets/IDMPhotoBrowser.bundle'
  s.resource_bundles = {
    'FSPhotoBrowser' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
s.framework     =  'MessageUI', 'QuartzCore', 'SystemConfiguration', 'MobileCoreServices', 'Security'
s.dependency       'AFNetworking'
s.dependency       'DACircularProgress'
s.dependency       'pop'
s.dependency       'TTTAttributedLabel'
end
