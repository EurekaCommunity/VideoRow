Pod::Spec.new do |s|
  s.name             = 'VideoRow'
  s.version          = '0.1.1'
  s.summary          = 'Eureka row that allows us to take or select a video.'
  s.description      = <<-DESC
This is an add-on to the many rows that are in the Eureka Community. This row will allow users to select a video from there library to export to a backend service of there choosing.
                       DESC
  s.homepage         = 'https://github.com/EurekaCommunity/VideoRow'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Smiller193' => 'shawn.miller@temple.edu' }
  s.source           = { :git => 'https://github.com/EurekaCommunity/VideoRow.git', :tag => s.version.to_s }
   s.social_media_url = 'https://twitter.com/EurekaCommunity'

  s.ios.deployment_target = '10.0'

  s.source_files = 'VideoRow/Classes/**/*'
  s.platform = :ios, "10.0"
  s.dependency 'TLPhotoPicker'
  s.dependency 'Eureka'
  s.swift_version = '4.2'
end
