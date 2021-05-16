Pod::Spec.new do |s|

  s.name         = "VLCMediaLibraryKit"
  s.version      = '0.8.0b1'
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
   :http => 'https://download.videolan.org/pub/cocoapods/prod/VLCMediaLibraryKit-0.8.0b1-be9e1a2-f624aad5.zip',
   :sha256 => 'd3fec3448f3ad9910b4468fe4183dfcb761425e73e273ec58cd56342b2efab22'
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
