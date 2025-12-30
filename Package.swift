// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MobileCLIP",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MobileCLIP",
            targets: ["MobileCLIP"]
        ),
        .executable(
            name: "embeddings",
            targets: [
                "Embeddings"
            ])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.6.4")
      ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MobileCLIP",
            resources: [
                .process("Resources/clip-merges.txt"),
                .process("Resources/clip-vocab.json"),
            ],
        ),
        .executableTarget(
            name: "Embeddings",
            dependencies: [
                "MobileCLIP",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
            ],
            resources: [
                .process("../MobileCLIP/Resources/clip-merges.txt"),
                .process("../MobileCLIP/Resources/clip-vocab.json"),
                .copy("Resources/mobileclip_s2_image.mlmodelc"),
                .copy("Resources/mobileclip_s2_text.mlmodelc"),
            ]
        ),
    ]
)
