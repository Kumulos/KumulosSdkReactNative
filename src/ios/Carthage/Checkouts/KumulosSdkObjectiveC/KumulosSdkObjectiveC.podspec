
Pod::Spec.new do |s|
  s.name = "KumulosSdkObjectiveC"
  s.version = "1.6.6"
  s.license = "MIT"
  s.summary = "Official Objective-C SDK for integrating Kumulos services with your mobile apps"
  s.homepage = "https://github.com/Kumulos/KumulosSdkObjectiveC"
  s.authors = { "Kumulos Ltd" => "support@kumulos.com" }
  s.source = { :git => "https://github.com/Kumulos/KumulosSdkObjectiveC.git", :tag => "#{s.version}" }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.12"

  s.source_files = "Sources"
  s.exclude_files = "Carthage"
  s.module_name = "KumulosSDK"
  s.header_dir = "KumulosSDK"
  s.preserve_path = 'upload_dsyms.sh'

  s.prepare_command = 'chmod +x upload_dsyms.sh'

  s.osx.exclude_files = ['Sources/*Push*', 'Sources/*Analytics*', 'Sources/*Location*']

  s.ios.public_header_files = [
      'Sources/KumulosSDK.h',
      'Sources/Kumulos.h',
      'Sources/KSAPIOperation.h',
      'Sources/KSAPIResponse.h',
      'Sources/Kumulos+Push.h',
      'Sources/KumulosPushSubscriptionManager.h',
      'Sources/Kumulos+Location.h',
      'Sources/Kumulos+Crash.h',
      'Sources/Kumulos+Analytics.h'
  ]

  s.ios.resources = 'Sources/KAnalyticsModel.xcdatamodeld'

  s.osx.public_header_files = [
      'Sources/KumulosSDK.h',
      'Sources/Kumulos.h',
      'Sources/KSAPIOperation.h',
      'Sources/KSAPIResponse.h',
      'Sources/Kumulos+Crash.h'
  ]

  s.dependency "AFNetworking", "~> 3.1.0"
  s.dependency "KSCrash", "~> 1.15"
end
