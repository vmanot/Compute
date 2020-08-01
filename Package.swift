// swift-tools-version:5.2

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
        .package(url: "git@github.com:vmanot/LinearAlgebra", .branch("master")),
        .package(url: "git@github.com:vmanot/Swallow", .branch("master"))
    ],
    targets: [
        .target(name: "Compute", dependencies: ["LinearAlgebra", "Swallow"], path: "Sources")
    ]
)
