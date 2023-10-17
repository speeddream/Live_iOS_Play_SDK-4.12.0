source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!
target 'CCLiveCloud' do
pod 'Masonry'
pod 'Bugly'
pod 'SDWebImage', '5.14.2'
pod 'MBProgressHUD'
pod 'MJExtension'
pod 'MJRefresh'
pod 'YYWebImage'
pod 'YYCache'
pod 'YYImage'
pod 'YYText'
pod 'SnapKit'
pod 'AliyunOSSiOS'

# 基础SDK
pod 'CCLivePlaySDK', '4.12.0'
pod 'HDVideoClass_BSDK', '6.32.4'
pod 'AgoraRtcEngine_iOS', '3.7.2'
pod 'HDSAliyunPlayer'
pod 'HDStreamLib'
pod 'HDSCocoaLumberjack'
pod 'HDSSZip'

# 互动功能
pod 'HDSInteractionEngine',  '4.9.0'
pod 'HDSLikeModule',  '4.9.0'
pod 'HDSGiftModule',  '4.9.0'
pod 'HDSVoteModule',  '4.9.0'
pod 'HDSRedEnvelopeModule',  '4.9.0'
pod 'HDSInvitationCardModule',  '4.9.0'
pod 'HDSQuestionnaireModule',  '4.9.0'
pod 'HDSLiveStoreModule',  '4.9.0'

pod 'LookinServer', :configurations => ['Debug']
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
               end
          end
   end
end
