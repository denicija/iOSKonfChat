// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSKonfChatServer",
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.21.0"),
        .package(
            url: "https://github.com/apple/swift-argument-parser.git", from: "1.1.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "iOSKonfChatServer",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift"),
                .product(name: "ArgumentParser", package: "swift-argument-parser")],
            plugins: [
                .plugin(name: "GRPCSwiftPlugin", package: "grpc-swift")
            ])
    ]
)
