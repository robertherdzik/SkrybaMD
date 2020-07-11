// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SkrybaMD",
    products: [
        .executable(name: "SkrybaMD", targets: ["SkrybaMD"]),
        .library(name: "SkrybaMDCore", targets: ["SkrybaMDCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.4")
    ],
    targets: [
        .target(name: "SkrybaMD",
                dependencies: [
                    "SkrybaMDCore",
                    .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(
            name: "SkrybaMDCore",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(name: "SkrybaMDTests",
                    dependencies: [
                        "SkrybaMDCore"
        ]),
    ]
)
