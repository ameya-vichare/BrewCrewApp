// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProfileModule",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ProfileModule",
            targets: ["ProfileModule"]
        ),
    ],
    dependencies: [
        .package(path: "../../Core/AppCore"),
        .package(path: "../../Core/Networking"),
        .package(path: "../../Core/Persistence"),
        .package(path: "../../Feature/AuthModule"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ProfileModule",
            dependencies: [
                "AppCore",
                "Networking",
                "Persistence",
                "AuthModule"
            ]
        ),
        .testTarget(
            name: "ProfileModuleTests",
            dependencies: ["ProfileModule"]
        ),
    ]
)
