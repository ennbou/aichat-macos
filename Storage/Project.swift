import ProjectDescription

let project = Project(
    name: "Storage",
    organizationName: "AIChat",
    targets: [
        .target(
            name: "Storage",
            destinations: .macOS,
            product: .framework,
            bundleId: "com.ennbou.Storage",
            infoPlist: .default,
            sources: ["Sources/**"],
            resources: [],
            dependencies: [
                .sdk(name: "SwiftData", type: .framework)
            ]
        ),
        .target(
            name: "StorageTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "com.ennbou.StorageTests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [
                .target(name: "Storage")
            ]
        )
    ]
)
