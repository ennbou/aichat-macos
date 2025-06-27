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
            dependencies: [], 
            settings: .settings(configurations: [ 
                .debug(name: "Debug", xcconfig: "./xcconfigs/AIChat.xcconfig"), 
                .debug(name: "Release", xcconfig: "./xcconfigs/AIChat.xcconfig"), 
            ]) 
        ), 
    ]
)
