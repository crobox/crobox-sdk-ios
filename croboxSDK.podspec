
Pod::Spec.new do |spec|

  spec.name         = "croboxSDK"

  spec.version      = "1.0.31"

  spec.summary      = "Crobox SDK for iOS"

  spec.description  = "croboxSDK is a powerful SDK for integrating advanced analytics into your iOS applications. It provides seamless integration with minimal setup and offers a range of features to enhance your app's capabilities."

  spec.homepage     = "https://github.com/crobox/crobox-sdk-ios"

  spec.license      = "MIT"
 
  spec.license      = { :type => "MIT", :file => "LICENSE" }

  spec.authors      = { "Crobox" => "info@crobox.com" }

if spec.respond_to? 'swift_versions'
    spec.swift_versions = ['5.10.1']
  end

  spec.platform     = :ios
 
  spec.platform     = :ios, "13.0"

  spec.source       = { :git => "https://github.com/crobox/crobox-sdk-ios.git", :tag => "#{spec.version}" }

  spec.source_files = "Sources/**/*.{h,m,swift}"

  spec.dependency       'Alamofire'
  
  spec.dependency       'SwiftyJSON'

end
