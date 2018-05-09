Pod::Spec.new do |s|

  s.name         = "VLCMediaLibraryKit"
  s.version      = "1.0.0"
  s.summary      = "A MediaLibrary framework in Objective-C for iOS and OS X"

  s.description  = <<-DESC
                   A MediaLibrary framework in Objective-C for iOS and OS X
                   DESC

  s.homepage     = "https://code.videolan.org/videolan/VLCMediaLibraryKit"

  s.license      = { :type => "LGPLv2.1", :file => "COPYING" }

  s.authors            = {"Soomin Lee" => "bubu@mikan.io", "Felix Paul Kühne" => "fkuehne@videolan.org", "Carola Nitz" => "caro@videolan.org"}
  s.social_media_url   = "http://twitter.com/videolan"

  s.ios.deployment_target = "7.0"
  s.watchos.deployment_target = "2.0"
  # s.osx.deployment_target = "10.7"
  # s.tvos.deployment_target = "9.0"

  s.source       = { :git => "https://code.videolan.org/videolan/VLCMediaLibraryKit.git", :tag => "#{s.version}" }

  s.prefix_header_file = "VLCMediaLibraryKit_Prefix.pch"
  s.source_files  = "Headers/Internal/*.h", "Sources/*.m", "Sources/*.mm"
  s.public_header_files = "Headers/Public/*.h"

  s.header_dir = "VLCMediaLibraryKit"

  s.frameworks = "Foundation"
  s.library = 'sqlite3'

  s.requires_arc = true

  s.watchos.xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => "$(inherited) MLKIT_READONLY_TARGET" }
  s.ios.dependency "MobileVLCKit"

end
