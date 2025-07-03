// swift-tools-version: 5.9
import PackageDescription

#if TUIST
  import ProjectDescription

  let packageSettings = PackageSettings(
    // Customize the product types for specific package product
    // Default is .staticFramework
    // productTypes: ["Alamofire": .framework,]
    productTypes: [:]
  )
#endif

let package = Package(
  name: "AIChat",
  dependencies: [
    .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.0.0")
  ]
)
