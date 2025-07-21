import Foundation
import Observation
import Storage

protocol ChatSessionRepositoryProtocol {
  func create(chatSession: ChatSessionModel)
  func delete(chatSession: ChatSessionModel) -> Bool
  func update(chatSession: ChatSessionModel)
  func getAllSessions(sortBy: [SortDescriptor<ChatSessionModel>]?) -> [ChatSessionModel]
}

extension ChatSessionRepositoryProtocol {
  func getAllSessions(sortBy: [SortDescriptor<ChatSessionModel>]? = nil) -> [ChatSessionModel] {
    getAllSessions(sortBy: nil)
  }

}

class ChatSessionLocalStorage: ChatSessionRepositoryProtocol {
  static let shared = ChatSessionLocalStorage()

  private let sessionRepository: ChatSessionStorageRepositoryProtocol

  init(
    sessionRepository: ChatSessionStorageRepositoryProtocol = ChatSessionSwiftData()
  ) {
    self.sessionRepository = sessionRepository
  }

  // MARK: - Chat Session Operations

  func create(chatSession: ChatSessionModel) {
    do {
      try sessionRepository.save(chatSession: chatSession)
    } catch {

    }
  }

  func delete(chatSession: ChatSessionModel) -> Bool {
    do {
      try sessionRepository.delete(chatSession: chatSession)
      return true
    } catch {
      return false
    }
  }

  func update(chatSession: ChatSessionModel) {
    chatSession.lastModifiedAt = Date()
    do {
      try sessionRepository.update(chatSession: chatSession)
    } catch {

    }
  }

  // MARK: - Message Operations

  @discardableResult
  func addMessage(
    content: String,
    isUserMessage: Bool,
    to session: ChatSessionModel
  ) -> MessageModel {
    let message = MessageModel(content: content, isUserMessage: isUserMessage, chatSession: session)
    sessionRepository.addMessage(message, to: session)
    return message
  }

  // MARK: - Query Helpers

  func getAllSessions(sortBy: [SortDescriptor<ChatSessionModel>]? = nil) -> [ChatSessionModel] {
    return sessionRepository.fetchAll(sortBy: sortBy)
  }

  // MARK: - Data Refresh

  func refreshSessions() {
  }

  // MARK: - Data Migration Helpers

  /// Reset and rebuild the database - for use in cases of severe migration errors
  func resetDatabase() {
    // Reset the database
    sessionRepository.resetDatabase()

    // Refresh with empty data
    refreshSessions()

    // Create a default session
    create(chatSession: ChatSessionModel(title: "New Chat"))
  }
}
