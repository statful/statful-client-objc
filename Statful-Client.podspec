Pod::Spec.new do |s|
  s.name     = 'Statful-Client'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'Statful Client for iOS & macOS written in Objective-C.'
  s.homepage = ''
  s.author   = { 'Tiago Ferreira' => 'tiago.ferreira@mindera.com' }
  s.source   = { :git => '', :tag => s.version }

  s.ios.deployment_target = '6.0'
  s.ios.frameworks = 'MobileCoreServices', 'SystemConfiguration', 'Security'

  s.osx.deployment_target = '10.8'
  s.osx.frameworks = 'CoreServices', 'SystemConfiguration', 'Security'

  s.source_files = 'src/*.{h,m}'
  #s.private_header_files = ''

  s.dependency 'CocoaLumberjack', '~> 2.0.0'
  s.dependency 'CocoaAsyncSocket', '~> 7.4.2'
  s.dependency 'AFNetworking', '~> 2.5'
end
