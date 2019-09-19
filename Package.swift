// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Barca",
    platforms: [.macOS(.v10_10)],
    products: [
        .library(
            name: "BarcaKit",
            targets: ["BarcaKit"]),
        .executable(name: "barca",
                    targets: ["Barca"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/XcodeProj.git",
                 .upToNextMinor(from: "7.0.0")),
        .package(url: "https://github.com/kylef/Commander.git",
                 .upToNextMinor(from: "0.9.0")),
        .package(url: "https://github.com/dduan/TOMLDecoder.git",
                 .upToNextMinor(from: "0.1.3")),
        .package(url: "https://github.com/jdhealy/PrettyColors.git",
                 .upToNextMinor(from: "5.0.0")),
    ],
    targets: [
        .target(
            name: "BarcaKit",
            dependencies: ["XcodeProj", "TOMLDecoder"]),
        .target(
            name: "Barca",
            dependencies: ["BarcaKit", "Commander", "PrettyColors"]),
        .testTarget(
            name: "BarcaKitTests",
            dependencies: ["BarcaKit"]),
    ]
)
