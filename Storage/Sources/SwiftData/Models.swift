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
}

/// An example model for messages
@Model
public final class MessageModel {
    /// Unique identifier for the message
    public var id: UUID
    /// The content of the message
    public var content: String
    /// Whether the message is from the user or the AI
    public var isUserMessage: Bool
    /// When the message was sent
    public var timestamp: Date
    
    /// Reference to the chat session this message belongs to
    @Relationship(inverse: \ChatSessionModel.messages)
    public var chatSession: ChatSessionModel?
    
    /// Initialize a new message
    public init(
        id: UUID = UUID(),
        content: String,
        isUserMessage: Bool,
        timestamp: Date = Date(),
        chatSession: ChatSessionModel? = nil
    ) {
        self.id = id
        self.content = content
        self.isUserMessage = isUserMessage
        self.timestamp = timestamp
        self.chatSession = chatSession
    }
}
