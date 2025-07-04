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
      scripts: [
        .pre(
          script:
            "git diff --name-only HEAD | grep '\\.swift$' | xargs -n1 xcrun swift-format format -i",
          name: "Swift Format",
          basedOnDependencyAnalysis: false
        ),
        .pre(
          script: "git diff --name-only HEAD | grep '\\.swift$' | xargs -n1 swiftlint lint",
          name: "Swift Lint",
          basedOnDependencyAnalysis: false
        ),
      ],
      dependencies: [
        .project(target: "Networking", path: .relativeToRoot("Networking")),
        .project(target: "Storage", path: .relativeToRoot("Storage")),
        .external(name: "MarkdownUI"),
      ],
      settings: .settings(configurations: [
        .debug(name: "Debug", xcconfig: "./xcconfigs/AIChat.xcconfig"),
        .debug(name: "Release", xcconfig: "./xcconfigs/AIChat.xcconfig"),
      ])
    )
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
    )
  ]
)
