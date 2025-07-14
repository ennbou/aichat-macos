import Foundation
import SwiftData

/// An example model for chat sessions
@Model
public final class ChatSessionModel {
  /// Unique identifier for the session
  public var id: UUID
  /// Title of the chat session
  public var title: String
  /// When the session was created
  public var createdAt: Date
  /// When the session was last modified
  public var lastModifiedAt: Date
  /// Whether the session is archived
  public var isArchived: Bool = false
  /// Messages in this session
  @Relationship(deleteRule: .cascade)
  public var messages: [MessageModel]

  /// Initialize a new chat session
  public init(
    id: UUID = UUID(),
    title: String,
    createdAt: Date = Date(),
    lastModifiedAt: Date = Date(),
    isArchived: Bool = false,
    messages: [MessageModel] = []
  ) {
    self.id = id
    self.title = title
    self.createdAt = createdAt
    self.lastModifiedAt = lastModifiedAt
    self.isArchived = isArchived
    self.messages = messages
  }

  public func updateLastActivity() {
    self.lastModifiedAt = Date()
  }

  // Check if the session has no messages
  public var isEmpty: Bool {
    return messages.isEmpty
  }
}
