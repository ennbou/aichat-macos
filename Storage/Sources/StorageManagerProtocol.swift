import Foundation

/// Protocol defining the storage operations
public protocol StorageManagerProtocol {
    func save<T: Encodable>(_ object: T, forKey key: String) throws
    func retrieve<T: Decodable>(forKey key: String, as type: T.Type) throws -> T
    func delete(forKey key: String) throws
    func exists(forKey key: String) -> Bool
}

/// Errors that can be thrown by the StorageManager
public enum StorageError: Error {
    case saveFailure
    case retrieveFailure
    case deleteFailure
    case notFound
}
