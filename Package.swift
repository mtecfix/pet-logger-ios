// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PetLogger",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(name: "PetLogger", targets: ["PetLogger"])
    ],
    dependencies: [
        .package(url: "https://github.com/aws-amplify/amplify-swift", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "PetLogger",
            dependencies: [
                .product(name: "Amplify", package: "amplify-swift"),
                .product(name: "AWSCognitoAuthPlugin", package: "amplify-swift"),
                .product(name: "AWSAPIPlugin", package: "amplify-swift"),
                .product(name: "AWSS3StoragePlugin", package: "amplify-swift")
            ]
        ),
        .testTarget(name: "PetLoggerTests", dependencies: ["PetLogger"])
    ]
)
