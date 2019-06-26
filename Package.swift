// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "PrettyStackTrace",
  products: [
    .library(
      name: "PrettyStackTrace",
      targets: ["PrettyStackTrace"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-package-manager.git", from: "0.1.0"),
    .package(url: "https://github.com/llvm-swift/Symbolic.git", from: "0.0.1"),
    .package(url: "https://github.com/llvm-swift/FileCheck.git", from: "0.2.0"),
    .package(url: "https://github.com/llvm-swift/Lite.git", from: "0.0.3"),
  ],
  targets: [
    .target(name: "PrettyStackTrace", dependencies: []),
    .target(name: "pst-lite", dependencies: ["LiteSupport", "SPMUtility", "Symbolic", "filecheck"]),
  ]
)
