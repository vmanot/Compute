// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Compute",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "Compute", targets: ["Compute"])
    ],
    dependencies: [
        .package(path: "../LinearAlgebra"),
        .package(path: "../Swallow")
    ],
    targets: [
        .target(name: "Compute", dependencies: ["LinearAlgebra", "Swallow"], path: "Sources")
    ],
    swiftLanguageVersions: [
        .version("5.1")
    ]
)
