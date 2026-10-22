// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "upi_intent",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "upi-intent", targets: ["upi_intent"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "upi_intent",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
