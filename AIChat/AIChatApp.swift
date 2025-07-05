//
//  AIChatApp.swift
//  AIChat
//
//  Created by Bouch on 6/25/25.
//

import Storage
import SwiftUI

@main
struct AIChatApp: App {
  // Use the SwiftDataManager from Storage module
  let swiftDataManager = StorageFactory.shared.swiftDataManager
  @State private var databaseErrorOccurred = false

  var body: some Scene {
    WindowGroup {
      ChatScreen()
        .modelContainer(swiftDataManager.modelContainer)
        .onAppear {
          // Verify database health when app appears
          if !swiftDataManager.checkDatabaseHealth() {
            databaseErrorOccurred = true
          }
        }
        .alert("Database Error", isPresented: $databaseErrorOccurred) {
          Button("Reset Database") {
            // Reset the database if there's an error
            ChatRepository.shared.resetDatabase()
            databaseErrorOccurred = false
          }
          Button("Continue Anyway", role: .cancel) {
            databaseErrorOccurred = false
          }
        } message: {
          Text(
            "There was an issue with the database. You can reset the database or continue with potential issues."
          )
        }
    }

    WindowGroup(id: "settings", for: String.self) { _ in
      SettingScreen()
        .modelContainer(swiftDataManager.modelContainer)
    }
  }
}
