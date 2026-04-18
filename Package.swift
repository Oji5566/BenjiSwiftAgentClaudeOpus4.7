// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BenjiCore",
    products: [
        .library(name: "BenjiCore", targets: ["BenjiCore"])
    ],
    targets: [
        .target(name: "BenjiCore"),
        .testTarget(name: "BenjiCoreTests", dependencies: ["BenjiCore"])
    ]
)
