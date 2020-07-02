#
#  Be sure to run `pod spec lint WebRTCKurento.podspec.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "WebRTCKurento"
  spec.version      = "1.0.1"
  spec.summary      = "A CocoaPods library written in Swift"
  spec.description  = <<-DESC
  This CocoaPods library helps you stream or call video.
                     DESC
  spec.homepage     = "https://github.com/zinzin186/WebRTCKurento"
  spec.license      = "MIT"
  spec.author             = { "Zinzin" => "vudinhdin@gmail.com.vn" }
  spec.platform     = :ios, "10.3"
  spec.source       = { :git => "https://github.com/zinzin186/WebRTCKurento.git", :tag => "#{spec.version}" }
  spec.swift_version = "4.0"
  spec.source_files  = "WebRTCKurento/**/*.{h,m,swift}"
  

end
