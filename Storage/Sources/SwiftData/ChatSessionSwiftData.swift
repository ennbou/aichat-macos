import Foundation
import SwiftData

public protocol ChatSessionRepositoryProtocol {
  func save(_ chatSession: ChatSessionModel)
  func update(_ chatSession: ChatSessionModel)
  func delete(_ chatSession: ChatSessionModel)
  func fetchAll(sortBy: [SortDescriptor<ChatSessionModel>]?) -> [ChatSessionModel]
  func resetDatabase()
  func addMessage(_ message: MessageModel, to chatSession: ChatSessionModel)
  func find(byId id: UUID) -> ChatSessionModel?
}

/// Repository for managing ChatSession models
public class ChatSessionSwiftData: ChatSessionRepositoryProtocol {
  private let swiftDataManager: SwiftDataManager

  /// Initialize with a SwiftData manager
  public init(swiftDataManager: SwiftDataManager = SwiftDataManager.shared) {
    self.swiftDataManager = swiftDataManager
  }

  /// Save a new chat session
  public func save(_ chatSession: ChatSessionModel) {
    swiftDataManager.mainContext.insert(chatSession)
    swiftDataManager.saveContext()
  }

  /// Update an existing chat session
  public func update(_ chatSession: ChatSessionModel) {
    chatSession.lastModifiedAt = Date()
    swiftDataManager.saveContext()
  }

  /// Delete a chat session
  public func delete(_ chatSession: ChatSessionModel) {
    swiftDataManager.delete(chatSession)
    swiftDataManager.saveContext()
  }

  /// Fetch all chat sessions
  public func fetchAll(sortBy: [SortDescriptor<ChatSessionModel>]? = nil) -> [ChatSessionModel] {
    let defaultSort = [SortDescriptor(\ChatSessionModel.lastModifiedAt, order: .reverse)]
    do {
      return try swiftDataManager.fetch(ChatSessionModel.self, sortBy: sortBy ?? defaultSort)
    } catch {
      print("Error fetching chat sessions: \(error)")
      return []
    }
  }

  /// Find a chat session by ID
  public func find(byId id: UUID) -> ChatSessionModel? {
    let predicate = #Predicate<ChatSessionModel> { $0.id == id }
    do {
      let results = try swiftDataManager.fetch(ChatSessionModel.self, predicate: predicate)
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
    swiftDataManager.saveContext()
  }

  public func resetDatabase() {
    swiftDataManager.resetDatabase()
  }
}
