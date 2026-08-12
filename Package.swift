// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PetLogger",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "PetLogger", targets: ["PetLogger"])
    ],
    targets: [
        .target(
            name: "PetLogger",
            path: "PetLogger"
        )
    ]
)
