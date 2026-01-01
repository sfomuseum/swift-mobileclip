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
            ]),
        .executable(
            name: "server",
            targets: [
                "Server"
            ])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.6.4"),
        .package(url: "https://github.com/grpc/grpc-swift-2.git", from: "2.0.0"),
        .package(url: "https://github.com/grpc/grpc-swift-protobuf.git", from: "2.0.0"),
        .package(url: "https://github.com/grpc/grpc-swift-nio-transport.git", from: "2.1.0"),
        .package(url: "https://github.com/sfomuseum/swift-coregraphics-image.git", from: "1.0.1"),
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
            ]
        ),
        .executableTarget(
            name: "Server",
            dependencies: [
                "MobileCLIP",
                .product(name: "GRPCCore", package: "grpc-swift-2"),
                .product(name: "GRPCNIOTransportHTTP2", package: "grpc-swift-nio-transport"),
                .product(name: "GRPCProtobuf", package: "grpc-swift-protobuf"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "CoreGraphicsImage", package: "swift-coregraphics-image"),
            ],
            resources: [
                .process("../MobileCLIP/Resources/clip-merges.txt"),
                .process("../MobileCLIP/Resources/clip-vocab.json"),
            ]
        ),
    ]
)
