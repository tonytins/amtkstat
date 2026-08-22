// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "AmtrakStatus",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .macCatalyst(.v13)],
    dependencies: [
        .package(
            url: "https://github.com/moreSwift/swift-cross-ui",
            .upToNextMinor(from: "0.7.0"),
        ),
    ],
    targets: [
        .executableTarget(
            name: "AmtrakStatus",
            dependencies: [
                .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
                .product(name: "DefaultBackend", package: "swift-cross-ui"),
            ],
        ),
    ],
)
