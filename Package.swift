// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BookScout",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "AppCore", targets: ["AppCore"]),
        .library(name: "BookDomain", targets: ["BookDomain"]),
        .library(name: "BookData", targets: ["BookData"]),
        .library(name: "BookFeature", targets: ["BookFeature"])
    ],
    targets: [
        .target(name: "AppCore"),
        .target(name: "BookDomain", dependencies: ["AppCore"]),
        .target(name: "BookData", dependencies: ["AppCore", "BookDomain"]),
        .target(name: "BookFeature", dependencies: ["AppCore", "BookDomain"]),
        .testTarget(name: "BookDomainTests", dependencies: ["AppCore", "BookDomain"]),
        .testTarget(name: "BookDataTests", dependencies: ["AppCore", "BookDomain", "BookData"])
    ]
)
