import Foundation
import SwiftData

public protocol ChatSessionStorageRepositoryProtocol {
  var dataManager: DataManagerProtocol { get }
  func save(chatSession: ChatSessionModel) throws
  func update(chatSession: ChatSessionModel) throws
  func delete(chatSession: ChatSessionModel) throws
  func fetchAll(sortBy: [SortDescriptor<ChatSessionModel>]?) -> [ChatSessionModel]
  func resetDatabase()
  func addMessage(_ message: MessageModel, to chatSession: ChatSessionModel)
  func find(byId id: UUID) -> ChatSessionModel?
}

/// Repository for managing ChatSession models
public class ChatSessionSwiftData: ChatSessionStorageRepositoryProtocol {
  public var dataManager: any DataManagerProtocol

  /// Initialize with a SwiftData manager
  public init(dataManager: DataManagerProtocol = SwiftDataManager.shared) {
    self.dataManager = dataManager
  }

  /// Save a new chat session
  public func save(chatSession: ChatSessionModel) throws {
    dataManager.mainContext.insert(chatSession)
    try dataManager.saveContext()
  }

  /// Update an existing chat session
  public func update(chatSession: ChatSessionModel) throws {
    chatSession.lastModifiedAt = Date()
    try dataManager.saveContext()
  }

  /// Delete a chat session
  public func delete(chatSession: ChatSessionModel) throws {
    dataManager.delete(chatSession)
    try dataManager.saveContext()
  }

  /// Fetch all chat sessions
  public func fetchAll(sortBy: [SortDescriptor<ChatSessionModel>]? = nil) -> [ChatSessionModel] {
    let defaultSort = [SortDescriptor(\ChatSessionModel.lastModifiedAt, order: .reverse)]
    do {
      return try dataManager.fetch(ChatSessionModel.self, sortBy: sortBy ?? defaultSort)
    } catch {
      print("Error fetching chat sessions: \(error)")
      return []
    }
  }

  /// Find a chat session by ID
  public func find(byId id: UUID) -> ChatSessionModel? {
    do {
      let predicate = #Predicate<ChatSessionModel> { session in
        session.id == id
      }
      let results = try dataManager.fetch(ChatSessionModel.self, predicate: predicate)
      return results.first
    } catch {
      print("Error finding chat session: \(error)")
      return nil
    }
  }

  /// Add a message to a chat session
  public func addMessage(_ message: MessageModel, to chatSession: ChatSessionModel) {
    chatSession.messages.append(message)
    chatSession.lastModifiedAt = Date()
    try? dataManager.saveContext()
  }

  public func resetDatabase() {
    dataManager.resetDatabase()
  }
}
