// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorBranchDeepLinks",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "CapacitorBranchDeepLinks",
            targets: ["BranchDeepLinksPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0"),
        .package(url: "https://github.com/BranchMetrics/ios-branch-sdk-spm.git", from: "3.14.0") 
    ],
    targets: [
        .target(
            name: "BranchDeepLinksPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                // The dedicated SPM repo exports "BranchSDK"
                .product(name: "BranchSDK", package: "ios-branch-sdk-spm")
            ],
            path: "ios/Plugin"
        )
    ]
)