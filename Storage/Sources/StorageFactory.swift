import Foundation
import Combine
@_exported import SwiftData

/// A factory that provides storage-related services
public class StorageFactory {
    
    /// The shared instance of the storage factory
    public static let shared = StorageFactory()
    
    /// The storage manager instance
    public let storageManager: StorageManagerProtocol
    
    /// The SwiftData manager instance
    public let swiftDataManager: SwiftDataManager
    
    /// Private initializer to enforce singleton pattern
    private init(
        storageManager: StorageManagerProtocol = StorageManager(),
        swiftDataManager: SwiftDataManager = SwiftDataManager.shared
    ) {
        self.storageManager = storageManager
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
    
    /// Reset the database - useful for handling migration errors
    public func resetDatabase() {
        swiftDataManager.resetDatabase()
    }
}

extension NSNotification.Name {
    static var modelDocumentBecameInvalid: NSNotification.Name {
        return NSNotification.Name("ModelDocumentBecameInvalid")
    }
}
