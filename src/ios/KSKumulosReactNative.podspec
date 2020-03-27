
Pod::Spec.new do |s|
  s.name         = "KSKumulosReactNative"
  s.version      = "1.0.0"
  s.summary      = "KSKumulosReactNative"
  s.description  = <<-DESC
                  KSKumulosReactNative
                   DESC
  s.homepage     = ""
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/author/KSKumulosReactNative.git", :tag => "master" }
  s.source_files  = "KSKumulosReactNative/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  s.dependency "KumulosSDKObjectiveC", "~> 1.8"

end

