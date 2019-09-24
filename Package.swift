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
                    targets: ["Barca"])
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/XcodeProj.git",
                 .upToNextMinor(from: "7.0.0")),
        .package(url: "https://github.com/Carthage/Commandant",
                 .upToNextMinor(from: "0.17.0")),
        .package(url: "https://github.com/dduan/TOMLDecoder.git",
                 .upToNextMinor(from: "0.1.3")),
        .package(url: "https://github.com/jdhealy/PrettyColors.git",
                 .upToNextMinor(from: "5.0.0")),
        .package(url: "https://github.com/tuist/shell.git",
                 from: "2.0.0"),
        .package(url: "https://github.com/kylef/PathKit.git",
                 from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "BarcaKit",
            dependencies: ["XcodeProj", "TOMLDecoder", "Shell", "PathKit", "PrettyColors"]),
        .target(
            name: "Barca",
            dependencies: ["BarcaKit", "Commandant"]),
        .testTarget(
            name: "BarcaKitTests",
            dependencies: ["BarcaKit", "ShellTesting"])
    ]
)
