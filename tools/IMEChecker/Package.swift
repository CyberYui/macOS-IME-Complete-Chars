// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "IMEChecker",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "IMEChecker",
            path: "Sources/IMEChecker",
            linkerSettings: [
                .linkedFramework("Carbon"),
                .linkedFramework("ApplicationServices"),
                .linkedFramework("Vision"),
                .linkedFramework("AppKit"),
            ]
        )
    ]
)
