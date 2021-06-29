Pod::Spec.new do |s|

  s.name         = "VLCMediaLibraryKit"
  s.version      = '0.8.1b1'
  s.summary      = "A MediaLibrary framework in Objective-C for iOS and OS X"

  s.description  = <<-DESC
                   A MediaLibrary framework in C++ wrapped in Objective-C for iOS
                   DESC

  s.homepage     = "https://code.videolan.org/videolan/VLCMediaLibraryKit"

  s.license      = { :type => 'LGPLv2.1', :file => 'COPYING' }

  s.authors            = { "Soomin Lee" => "bubu@mikan.io", "Felix Paul Kühne" => "fkuehne@videolan.org", "Carola Nitz" => "caro@videolan.org" }
  s.social_media_url   = "http://twitter.com/videolan"

  s.ios.deployment_target = '9.0'

  s.source = {
   :http => 'https://download.videolan.org/pub/cocoapods/prod/VLCMediaLibraryKit-0.8.1b1-4334c78-5b4c2180.zip',
   :sha256 => '269c4edacbc1e27c583d53046180f5c715b05d84e56d08d7171ee10b8f30fed1'
  }
  s.ios.vendored_framework = 'VLCMediaLibraryKit.xcframework'

  s.frameworks = "Foundation"

  s.requires_arc = true

  s.ios.dependency "MobileVLCKit"
  s.xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
    'CLANG_CXX_LIBRARY' => 'libc++'
  }
end
