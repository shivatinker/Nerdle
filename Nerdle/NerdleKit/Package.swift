// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NerdleKit",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "NerdleKit",
            targets: ["NerdleKit"]
        ),
    ],
    targets: [
        .target(
            name: "NerdleKit"
        ),
        .testTarget(
            name: "NerdleKitTests",
            dependencies: ["NerdleKit"]
        ),
    ]
)
