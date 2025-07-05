import Foundation

/// Main storage manager class that handles saving and retrieving data
public class StorageManager: StorageManagerProtocol {
    
    private let fileManager: FileManager
    private let documentsDirectory: URL
    
    /// Initialize a storage manager
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        self.documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// Save an encodable object to disk
    public func save<T: Encodable>(_ object: T, forKey key: String) throws {
        let url = documentsDirectory.appendingPathComponent("\(key).data")
        
        do {
            let data = try JSONEncoder().encode(object)
            try data.write(to: url)
        } catch {
            throw StorageError.saveFailure
        }
    }
    
    /// Retrieve a decodable object from disk
    public func retrieve<T: Decodable>(forKey key: String, as type: T.Type) throws -> T {
        let url = documentsDirectory.appendingPathComponent("\(key).data")
        
        guard fileManager.fileExists(atPath: url.path) else {
            throw StorageError.notFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch {
            throw StorageError.retrieveFailure
        }
    }
    
    /// Delete an object from disk
    public func delete(forKey key: String) throws {
        let url = documentsDirectory.appendingPathComponent("\(key).data")
        
        guard fileManager.fileExists(atPath: url.path) else {
            throw StorageError.notFound
        }
        
        do {
            try fileManager.removeItem(at: url)
        } catch {
            throw StorageError.deleteFailure
        }
    }
    
    /// Check if an object exists on disk
    public func exists(forKey key: String) -> Bool {
        let url = documentsDirectory.appendingPathComponent("\(key).data")
        return fileManager.fileExists(atPath: url.path)
    }
}
