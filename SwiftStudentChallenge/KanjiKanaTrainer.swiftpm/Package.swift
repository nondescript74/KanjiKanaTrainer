// swift-tools-version: 5.9

// WARNING:
// This is an app playground (.swiftpm) for the Swift Student Challenge.
// Open it in Swift Playground 4.6+ or Xcode 26+.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "KanjiKanaTrainer",
    platforms: [
        .iOS("17.0")
    ],
    products: [
        .iOSApplication(
            name: "KanjiKanaTrainer",
            targets: ["AppModule"],
            bundleIdentifier: "com.headydiscy.KanjiKanaTrainer.playground",
            teamIdentifier: "",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .pencil),
            accentColor: .presetColor(.red),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            exclude: ["README.md", "CREDITS.md"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
