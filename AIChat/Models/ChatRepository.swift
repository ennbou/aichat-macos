//
//  ChatRepository.swift
//  AIChat
//
//  Created on 7/4/25.
//

import Combine
import Foundation
import Storage

/// A helper class that bridges between the AIChat app and the Storage module
class ChatRepository: ObservableObject {
  static let shared = ChatRepository()

  private let sessionRepository: ChatSessionRepository
  private let swiftDataManager: SwiftDataManager

  @Published var chatSessions: [ChatSessionModel] = []

  init(
    sessionRepository: ChatSessionRepository = ChatSessionRepository(),
    swiftDataManager: SwiftDataManager = StorageFactory.shared.swiftDataManager
  ) {
    self.sessionRepository = sessionRepository
    self.swiftDataManager = swiftDataManager

    // Load sessions initially
    refreshSessions()
  }

  // MARK: - Chat Session Operations

  func createSession(title: String) -> ChatSessionModel {
    let session = ChatSessionModel(title: title)
    sessionRepository.save(session)
    // Immediately refresh the sessions list to update UI
    refreshSessions()
    return session
  }

  func deleteSession(_ session: ChatSessionModel) {
    sessionRepository.delete(session)
    // Immediately refresh the sessions list to update UI
    refreshSessions()
  }

  func updateSession(_ session: ChatSessionModel) {
    session.lastModifiedAt = Date()
    sessionRepository.update(session)
    // Immediately refresh the sessions list to update UI
    refreshSessions()
  }

  // MARK: - Message Operations

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

  func findSession(byId id: UUID) -> ChatSessionModel? {
    return sessionRepository.find(byId: id)
  }

  // MARK: - Data Refresh

  func refreshSessions() {
    chatSessions = getAllSessions()
  }

  // MARK: - Data Migration Helpers

  /// Reset and rebuild the database - for use in cases of severe migration errors
  func resetDatabase() {
    // Reset the database
    swiftDataManager.resetDatabase()

    // Refresh with empty data
    refreshSessions()

    // Create a default session
    _ = createSession(title: "New Chat")

    // Refresh again to show the new session
    refreshSessions()
  }
}
