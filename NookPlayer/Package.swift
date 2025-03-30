// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "NookPlayer",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "NookPlayer", targets: ["NookPlayer"]),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "NookPlayer",
            dependencies: [],
            path: ".",
            exclude: ["NookPlayer.xcodeproj"],
            sources: ["NookPlayer.swift", "ContentView.swift"],
            resources: [
                .process("Assets.xcassets"),
                .process("Info.plist")
            ]
        ),
    ]
)
