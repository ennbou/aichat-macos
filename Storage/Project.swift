import ProjectDescription

let project = Project(
  name: "Storage",
  options: .options(
    automaticSchemesOptions: .disabled,
    disableBundleAccessors: false,
    disableSynthesizedResourceAccessors: false
  ),
  settings: .settings(configurations: [
      .debug(name: "Debug"),
      .release(name: "Release"),
  ]),
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
    ),
  ],
  schemes: [
      .scheme(
          name: "Storage",
          shared: true,
          buildAction: .buildAction(targets: ["Storage"]),
          testAction: .targets(
              ["StorageTests"],
              configuration: "Debug",
              options: .options(coverage: true, codeCoverageTargets: ["Storage"])
          ),
          runAction: .runAction(configuration: "Debug"),
          archiveAction: .archiveAction(configuration: "Release"),
          profileAction: .profileAction(configuration: "Release"),
          analyzeAction: .analyzeAction(configuration: "Debug")
      )
  ]
)
