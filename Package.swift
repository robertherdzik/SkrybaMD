// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SkrybaMD",
    products: [
        .executable(name: "SkrybaMD", targets: ["SkrybaMD"]),
        .library(name: "SkrybaMDCore", targets: ["SkrybaMDCore"])
    ],
    targets: [
        .target(name: "SkrybaMD",
                dependencies: ["SkrybaMDCore"]),
        .target(
            name: "SkrybaMDCore",
            dependencies: []
        ),
        .testTarget(name: "SkrybaMDTests",
                    dependencies: ["SkrybaMDCore"]),
    ]
)
