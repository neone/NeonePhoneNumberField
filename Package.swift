// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NeonePhoneNumberField",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "iPhoneNumberField",
            targets: ["iPhoneNumberField"]),
    ],
    dependencies: [
        .package(url: "https://github.com/marmelroy/PhoneNumberKit", .upToNextMajor(from: "4.2.7"))
    ],
    targets: [
        .target(
            name: "iPhoneNumberField",
            dependencies: ["PhoneNumberKit"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]),
        .testTarget(
            name: "NeonePhoneNumberFieldTests",
            dependencies: ["iPhoneNumberField"],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]),
    ]
)
