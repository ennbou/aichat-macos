//
//  AIChatApp.swift
//  AIChat
//
//  Created by Bouch on 6/25/25.
//

import AppKit
import SwiftData
import SwiftUI

@main
struct AIChatApp: App {
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Message.self,
      ChatSession.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  var body: some Scene {
    WindowGroup {
      ChatScreen()
    }
    .modelContainer(sharedModelContainer)

    WindowGroup(id: "settings", for: String.self) { _ in
      SettingScreen()
    }
  }
}
