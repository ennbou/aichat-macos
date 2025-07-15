import Storage
import SwiftData
import SwiftUI

@main
struct AIChatApp: App {
  // Use the SwiftDataManager from Storage module
  let swiftDataManager = SwiftDataManager.shared
  @State private var databaseErrorOccurred = false
  @Environment(\.openWindow) private var openWindow

  var body: some Scene {
    WindowGroup {
      ChatScreen()
        .modelContainer(swiftDataManager.modelContainer)
        .onAppear {
          if !swiftDataManager.checkDatabaseHealth() {
            databaseErrorOccurred = true
          }
        }
        .alert("Database Error", isPresented: $databaseErrorOccurred) {
          Button("Reset Database") {
            // Reset the database if there's an error
            swiftDataManager.resetDatabase()
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
    .commands {
      CommandGroup(replacing: .appSettings) {
        Button("Settings...") {
          openWindow(id: "settings", value: "settings")
        }
        .keyboardShortcut(",", modifiers: .command)
      }
    }

    WindowGroup(id: "settings", for: String.self) { _ in
      SettingScreen()
        .modelContainer(swiftDataManager.modelContainer)
    }
  }
}
