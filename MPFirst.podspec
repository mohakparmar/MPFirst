#
# Be sure to run `pod lib lint MPFirst.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MPFirst'
  s.version          = '0.2.0'
  s.summary          = 'This is my first pods'


  s.homepage         = 'https://github.com/mohakparmar/MPFirst'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mohakparmar' => 'mohak@infoware.ws' }
  s.source           = { :git => 'https://github.com/mohakparmar/MPFirst.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'MPFirst/Classes/**/*'
  
  #s.resource_bundles = {
  #    'MPFirst' => ['MPFirst/Assets/*.png']
  #}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
