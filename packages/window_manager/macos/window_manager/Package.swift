// swift-tools-version:5.39
import PackageDescription

let package = Package(
    name: "window_manager",
    platforms: [
        .macOS(.v10_11)
    ],
    products: [
        .library(
            name: "window_manager",
            targets: ["window_manager"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "window_manager",
            dependencies: [],
            resources: [
                // If your plugin requires a privacy manifest, for example if it collects user
                // data, update the PrivacyInfo.xcprivacy file to describe your plugin's
                // privacy impact, and then uncomment these lines. For more information, see
                // https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
                // .process("PrivacyInfo.xcprivacy"),

                // If you have other resources that need to be bundled with your plugin, refer to
                // the following instructions to add them:
                // https://developer.apple.com/documentation/xcode/bundling-resources-with-a-swift-package
            ]
        )
    ]
)
