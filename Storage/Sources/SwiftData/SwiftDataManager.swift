import Foundation
import SwiftData

/// Manager class for SwiftData operations
public class SwiftDataManager {
  /// The shared instance of the SwiftData manager
  public static var shared = SwiftDataManager()

  /// The model container
  public var modelContainer: ModelContainer

  /// The main context for the app
  public private(set) var mainContext: ModelContext

  /// Initialize with schema
  public init(inMemory: Bool = false) {
    do {
      // Create schema options to handle migration gracefully
      let schema = Schema([
        ChatSessionModel.self,
        MessageModel.self,
      ])

      // Use a simple configuration with automatic migration
      let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: inMemory,
        allowsSave: true
      )

      // Create the model container with our models
      modelContainer = try ModelContainer(
        for: schema,
        configurations: [configuration]
      )

      // Initialize the main context
      mainContext = ModelContext(modelContainer)
    } catch {
      print("Failed to create model container: \(error)")

      // Try creating an in-memory container as fallback
      do {
        let fallbackConfig = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(
          for: ChatSessionModel.self,
          MessageModel.self,
          configurations: fallbackConfig
        )
        mainContext = ModelContext(modelContainer)
        print("Using in-memory fallback database")
      } catch {
        fatalError("Failed to create even in-memory model container: \(error)")
      }
    }
  }

  /// Save the main context
  public func saveContext(_ context: ModelContext? = nil) {
    let contextToSave = context ?? mainContext
    do {
      try contextToSave.save()
    } catch {
      print("Error saving context: \(error)")
    }
  }

  /// Create a new context for isolated operations
  public func createNewContext() -> ModelContext {
    return ModelContext(modelContainer)
  }

  /// Fetch entities of a specific type with optional predicate
  public func fetch<T: PersistentModel>(
    _ type: T.Type,
    predicate: Predicate<T>? = nil,
    sortBy: [SortDescriptor<T>]? = nil
  ) throws -> [T] {
    let descriptor = FetchDescriptor<T>(predicate: predicate, sortBy: sortBy ?? [])
    return try mainContext.fetch(descriptor)
  }

  /// Delete an entity from the context
  public func delete<T: PersistentModel>(_ model: T, in context: ModelContext? = nil) {
    let contextToUse = context ?? mainContext
    contextToUse.delete(model)
  }

  /// Helper method to delete all models of a specific type
  public func deleteAll<T: PersistentModel>(_ type: T.Type) {
    do {
      let items = try fetch(type)
      for item in items {
        delete(item)
      }
      saveContext()
    } catch {
      print("Error deleting all \(type): \(error)")
    }
  }

  /// Reset the database - useful during significant schema changes
  public func resetDatabase() {
    do {
      // First delete all existing data
      deleteAll(ChatSessionModel.self)
      deleteAll(MessageModel.self)

      // Remove the persistent store
      try modelContainer.erase()

      // Create a new container with the same schema
      let schema = Schema([ChatSessionModel.self, MessageModel.self])
      let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false,
        allowsSave: true
      )

      // Create a new manager instance
      let newManager = SwiftDataManager()

      // Replace the shared instance
      SwiftDataManager.shared = newManager

      print("Database successfully reset")
    } catch {
      print("Error resetting database: \(error)")

      // Create a fallback in-memory store if we can't reset properly
      do {
        let fallbackConfig = ModelConfiguration(isStoredInMemoryOnly: true)
        let schema = Schema([ChatSessionModel.self, MessageModel.self])
        modelContainer = try ModelContainer(for: schema, configurations: [fallbackConfig])
        print("Created fallback in-memory database")
      } catch {
        print("Critical error: Failed to create even in-memory database: \(error)")
      }
    }
  }

  /// Check if there are any issues with the database that would require a reset
  public func checkDatabaseHealth() -> Bool {
    do {
      // Try to fetch some data to see if database is working
      _ = try fetch(ChatSessionModel.self)
      _ = try fetch(MessageModel.self)
      return true
    } catch {
      print("Database health check failed: \(error)")
      return false
    }
  }
}
