import ProjectDescription

let MODULENAME = "Networking"

let project = Project(
  name: MODULENAME,
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
    ),
  ],
  schemes: [
    .scheme(
      name: MODULENAME,
      shared: true,
      buildAction: .buildAction(targets: ["\(MODULENAME)"]),
      testAction: .targets(
        ["\(MODULENAME)Tests"],
        configuration: "Debug",
        options: .options(coverage: true, codeCoverageTargets: ["\(MODULENAME)"])
      ),
      runAction: .runAction(configuration: "Debug"),
      archiveAction: .archiveAction(configuration: "Release"),
      profileAction: .profileAction(configuration: "Release"),
      analyzeAction: .analyzeAction(configuration: "Debug")
    )
  ]
)
