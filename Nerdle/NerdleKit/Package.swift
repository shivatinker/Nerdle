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
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", exact: "6.29.3"),
    ],
    targets: [
        .target(
            name: "NerdleKit",
            dependencies: [
                .product(name: "GRDB", package: "grdb.swift"),
            ]
        ),
        .testTarget(
            name: "NerdleKitTests",
            dependencies: ["NerdleKit"]
        ),
    ]
)
