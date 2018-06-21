
Pod::Spec.new do |s|
  s.name         = "KumulosSdkReactNative"
  s.version      = "2.0.0"
  s.summary      = "Native module for the official Kumulos React Native SDK. The SDK should be installed from the NPM kumulos-react-native package."
  s.description  = ""
  s.homepage     = "https://github.com/Kumulos/KumulosSdkReactNative"
  s.license      = "MIT"
  s.author       = { "Kumulos Ltd" => "support@kumulos.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/Kumulos/KumulosSdkReactNative.git", :tag => "wrap-native-sdks" }
  s.source_files  = "src/ios/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  s.dependency "KumulosSdkObjectiveC", "1.6.6"

end

