// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Claudet",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "claudet", targets: ["Claudet"])
    ],
    targets: [
        .executableTarget(
            name: "Claudet",
            path: "Sources/Claudet"
        )
    ]
)
