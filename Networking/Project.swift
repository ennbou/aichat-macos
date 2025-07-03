import ProjectDescription

let MODULENAME = "Networking"

let project = Project(
    name: MODULENAME,
    settings: .settings(configurations: [
        .debug(name: "Debug"),
        .release(name: "Release"),
    ]),
    targets: [
        .target(
            name: MODULENAME,
            destinations: .macOS,
            product: .framework,
            bundleId: "com.ennbou.AIChat.\(MODULENAME)",
            infoPlist: .default,
            sources: ["Sources/**"],
            dependencies: []
        ),
        .target(
            name: "\(MODULENAME)Tests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.ennbou.AIChat.\(MODULENAME)Tests",
            infoPlist: .default,
            sources: ["Tests/**"],
            dependencies: [
                .target(name: MODULENAME)
            ]
        )
    ]
)
