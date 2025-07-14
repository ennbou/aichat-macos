import ProjectDescription

let TARGETNAME = "AIChat"

let project = Project(
  name: TARGETNAME,
  options: .options(
    automaticSchemesOptions: .disabled,
    disableBundleAccessors: false,
    disableSynthesizedResourceAccessors: false
  ),
  settings: .settings(configurations: [
    .debug(name: "Debug", xcconfig: "./xcconfigs/AIChat-Project.xcconfig"),
    .release(name: "Release", xcconfig: "./xcconfigs/AIChat-Project.xcconfig"),
  ]),
  targets: [
    .target(
      name: TARGETNAME,
      destinations: .macOS,
      product: .app,
      bundleId: "com.ennbou.AIChat",
      infoPlist: .extendingDefault(with: [
        "CFBundleIconFile": "AppIcon.icns"
      ]),
      sources: ["AIChat/**"],
      resources: [
        "AIChat/Assets.xcassets",
        "AppIcon.icns",
      ],
      scripts: [],
      dependencies: [
        .project(target: "Networking", path: .relativeToRoot("Networking")),
        .project(target: "Storage", path: .relativeToRoot("Storage")),
        .external(name: "MarkdownUI"),
      ],
      settings: .settings(configurations: [
        .debug(name: "Debug", xcconfig: "./xcconfigs/AIChat.xcconfig"),
        .debug(name: "Release", xcconfig: "./xcconfigs/AIChat.xcconfig"),
      ])
    ),
    .target(
      name: "Code_Quality",
      destinations: .macOS,
      product: .commandLineTool,
      bundleId: "com.ennbou.AIChat.code.quality",
      scripts: [
        .pre(
          script: "git ls-files '*.swift' | xargs -n1 xcrun swift-format format -i",
          name: "Swift Format",
          basedOnDependencyAnalysis: false
        ),
        .pre(
          script: "git ls-files '*.swift' | xargs -n1 swiftlint --fix",
          name: "Swift Lint Fix",
          basedOnDependencyAnalysis: false
        ),
        .pre(
          script: "git ls-files '*.swift' | xargs -n1 swiftlint lint",
          name: "Swift Lint",
          basedOnDependencyAnalysis: false
        ),
        .pre(
          script: "periphery scan --format xcode",
          name: "Dead Code Scan",
          basedOnDependencyAnalysis: false
        ),
        .pre(
          script: "true || tuist graph --format png --output-path ./ --no-open",
          name: "Generate Dependency Graph",
          basedOnDependencyAnalysis: false
        ),
      ]
    ),
  ],
  schemes: [
    .scheme(
      name: TARGETNAME,
      shared: true,
      buildAction: .buildAction(
        targets: ["AIChat"],
        postActions: [
          .executionAction(
            title: "Inspect Build",
            scriptText: """
              eval \"$($HOME/.local/bin/mise activate -C $SRCROOT bash --shims)\"
              tuist inspect build
              """
          )
        ],
        runPostActionsOnFailure: true
      ),
      runAction: .runAction(configuration: "Debug")
    ),
    .scheme(
      name: "Code_Quality",
      shared: true,
      buildAction: .buildAction(
        targets: ["Code_Quality"]
      )
    ),
  ]
)
