

Pod::Spec.new do |s|


  s.name         = "CCLivePlaySDK"
  s.version      = '4.12.0'
  s.summary      = "An iOS SDK for CCLive Service"

  s.description  = <<-DESC
	It's  an iOS SDK for CCLive Service，It helps iOS developers to use CClive easier.
                   DESC
  s.homepage     = "http://hdgit.bokecc.com"

  s.license      = 'Apache License, Version 2.0'

  s.author             = { "CClive" => "service@bokecc.com" }

  s.platform     = :ios, "10.0"


  s.source       = { :git => "http://hdgit.bokecc.com/ccvideo/Live_iOS_Play_SDK.git", :tag => s.version.to_s }
  s.vendored_frameworks = 'SDK/Live_iOS_Play_SDK/*.{framework}'
  s.resource = 'SDK/Live_iOS_Play_SDK/CCBundle.bundle'
  s.dependency 'HDBaseUtils'

end
