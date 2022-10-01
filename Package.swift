// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ring",
    platforms: [.macOS(.v12)],
    dependencies: [
        .package(url: "https://github.com/ordo-one/package-benchmark", .upToNextMajor(from: "0.2.0")),
    ],
    targets: [
        .executableTarget(
            name: "swift-ring",
            dependencies: [
                .product(name: "BenchmarkSupport", package: "package-benchmark"),
            ],
            path: "Benchmarks/Ring"
        ),

    ]
)
