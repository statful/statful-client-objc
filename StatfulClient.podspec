#
# Be sure to run `pod lib lint StatfulClient.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'StatfulClient'
  s.version          = '1.0.0'
  s.summary          = 'Statful client to send metrics from macOS and iOS.'

  s.description      = <<-DESC
Statful client for macOS and iOS written in Objective-C. This client is intended to gather metrics and send them to the Statful service.
                       DESC

  s.homepage         = 'https://github.com/statful/statful-client-objc'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tiago Costa' => 'tiago.ferreira@mindera.com' }
  s.source           = { :git => 'https://github.com/statful/statful-client-objc.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.8'

  s.source_files = 'StatfulClient/Classes/**/*.{h,m}'
  s.public_header_files = 'Pod/Classes/SFClient.h','Pod/Classes/SFConstants.h','Pod/Classes/Logger/SFLogger.h','Pod/Classes/Communication/SFCommunicationProtocol.h'
  
  s.dependency 'CocoaLumberjack', '~> 2.0.0'
  s.dependency 'CocoaAsyncSocket', '~> 7.4.2'
  s.dependency 'AFNetworking', '~> 2.5'
end
