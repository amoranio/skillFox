// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Skillfox",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(name: "Skillfox", targets: ["Skillfox"]),
    ],
    targets: [
        .executableTarget(
            name: "Skillfox",
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)
