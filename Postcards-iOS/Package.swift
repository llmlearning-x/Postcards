// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Postcards",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "Postcards",
            targets: ["Postcards"]
        ),
    ],
    dependencies: [
        // 国内云服务 SDK（按需添加）
        // .package(url: "https://github.com/aliyun/aliyun-oss-ios-sdk", from: "2.10.0"),
    ],
    targets: [
        .target(
            name: "Postcards",
            path: "Postcards",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "PostcardsTests",
            dependencies: ["Postcards"],
            path: "PostcardsTests"
        ),
    ]
)
