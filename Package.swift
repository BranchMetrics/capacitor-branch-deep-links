// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorBranchDeepLinks",
    platforms: [.iOS(.v15)], // Standard minimum for Capacitor 8
    products: [
        .library(
            name: "CapacitorBranchDeepLinks",
            targets: ["BranchDeepLinksPlugin"])
    ],
    dependencies: [
        // 1. The Core Capacitor SPM package
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "8.0.0"),
        // 2. The Official Branch iOS SDK
        .package(url: "https://github.com/BranchMetrics/ios-branch-deep-linking-attribution", from: "3.4.0")
    ],
    targets: [
        .target(
            name: "BranchDeepLinksPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm"),
                // Link Branch directly to your plugin target
                .product(name: "Branch", package: "ios-branch-deep-linking-attribution") 
            ],
            // CRUCIAL: This path must match exactly where your Plugin.swift file lives!
            path: "ios/Plugin" 
        )
    ]
)