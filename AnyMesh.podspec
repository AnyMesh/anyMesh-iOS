Pod::Spec.new do |s|

  s.name         = "AnyMesh"
  s.version      = "0.3.0"
  s.summary      = "A multi-platform, decentralized, auto-discover and auto-connect mesh networking and messaging API"

  s.description  = "AnyMesh allows programs across devices and language platforms to communicate easily and effortlessly."
  s.homepage     = "https://github.com/AnyMesh/anyMesh-iOS"
  s.license      = "MIT (example)"
  s.author             = { "Dave Paul" => "davepaul0@gmail.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/AnyMesh/anyMesh-iOS.git", :tag => "0.3.0" }
  s.source_files  = "lib", "lib/*.{h,m}", "lib/CocoaAsyncSocket","lib/CocoaAsycSocket/*.{h,m}"

  s.requires_arc = true


end
