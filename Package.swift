// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Compute",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "Compute", targets: ["Compute"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", branch: "main"),
        .package(url: "https://github.com/vmanot/Diagnostics.git", branch: "main"),
        .package(url: "https://github.com/vmanot/Swallow.git", branch: "master")
    ],
    targets: [
        .target(
            name: "Compute",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                "Diagnostics",
                "Swallow"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ComputeTests",
            dependencies: [
                "Compute"
            ],
            path: "Tests"
        )
    ]
)
