import Combine
import Foundation
@_exported import SwiftData

/// A factory that provides storage-related services
public class StorageFactory {
  /// The shared instance of the storage factory
  public static let shared = StorageFactory()

  /// The SwiftData manager instance
  public let swiftDataManager: SwiftDataManager

  /// Private initializer to enforce singleton pattern
  private init(
    swiftDataManager: SwiftDataManager = SwiftDataManager.shared
  ) {
    self.swiftDataManager = swiftDataManager

    // Set up error handling for migrations
    setupErrorHandling()
  }

  /// Configure error handling for migrations
  private func setupErrorHandling() {
    // Listen for SwiftData schema mismatch errors
    NotificationCenter.default.addObserver(
      forName: NSNotification.Name.modelDocumentBecameInvalid,
      object: nil,
      queue: .main
    ) { notification in
      if let error = notification.userInfo?["error"] as? Error {
        print("SwiftData schema mismatch detected: \(error)")
      }
    }
  }
}

extension NSNotification.Name {
  static var modelDocumentBecameInvalid: NSNotification.Name {
    return NSNotification.Name("ModelDocumentBecameInvalid")
  }
}
