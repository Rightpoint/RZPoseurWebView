Pod::Spec.new do |s|
  s.name         = "RZPoseurWebView"
  s.version      = "1.0"
  s.summary      = "RZPoseurWebView is a library to simplify migrating from UIWebView to WKWebview."

  s.description  = <<-DESC
                   RZPoseurWebView is a library to simplify migrating from UIWebView to WKWebview.
				   
				   Features:
                   * Delegate-compatible replacement for UIWebView that's backed by WKWebView.
                   * If WKWebView is not available, RZPoseurWebView falls back on UIWebView.
                   DESC

  s.homepage     = "https://github.com/Raizlabs/RZPoseurWebView"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Justin Kaufman" => "jkaufman@raizlabs.com" }
  
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/Raizlabs/RZPoseurWebView.git", :tag => "1.0.0" }
  s.source_files  = "Classes/*.{h,m}", "Classes/Private/*.{h,m}"
  s.public_header_files = "Classes/*.h"
  s.private_header_files = "Classes/Private/*.h"
  s.frameworks    = "Foundation", "UIKit", "WebKit"
  s.requires_arc  = true

end