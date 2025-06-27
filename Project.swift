import ProjectDescription

let project = Project(
    name: "AIChat",
    settings: .settings(configurations: [
        .debug(name: "Debug", xcconfig: "./xcconfigs/AIChat-Project.xcconfig"),
        .release(name: "Release", xcconfig: "./xcconfigs/AIChat-Project.xcconfig"),
    ]),
    targets: [
        .target( 
            name: "AIChat", 
            destinations: .macOS, 
            product: .app,
            bundleId: "com.renault.AIChat",
            sources: ["AIChat/**"],
            scripts: [
                .pre(script: "git diff --name-only HEAD | grep '\\.swift$' | xargs -0 xcrun swift-format format -i", name: "Swift Format"),
                .pre(script: "git diff --name-only HEAD | grep '\\.swift$' | xargs -n1 swiftlint lint --path", name: "Swift Lint")
            ],
            dependencies: [],
            settings: .settings(configurations: [ 
                .debug(name: "Debug", xcconfig: "./xcconfigs/AIChat.xcconfig"), 
                .debug(name: "Release", xcconfig: "./xcconfigs/AIChat.xcconfig"), 
            ]) 
        ), 
    ]
)
