Pod::Spec.new do |s|

  s.name         = "VLCMediaLibraryKit"
  s.version      = '0.5.0'
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
   :http => 'https://download.videolan.org/pub/cocoapods/prod/VLCMediaLibraryKit-0.5.0-e473065-7d5f73e3.zip',
  }
  s.prefix_header_file = "VLCMediaLibraryKit_Prefix.pch"

  s.ios.vendored_framework = 'VLCMediaLibraryKit.framework'

  s.source_files = 'VLCMediaLibraryKit.framework/Headers/*.h'
  s.public_header_files = 'VLCMediaLibraryKit.framework/Headers/*.h'

  s.frameworks = "Foundation"
  s.library = 'sqlite3'

  s.requires_arc = true
  s.static_framework = true

  s.ios.dependency "MobileVLCKit"
  s.xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
    'CLANG_CXX_LIBRARY' => 'libc++'
  }
end
