//
//  ChatModel.swift
//  Storage
//
//  Created by Bouch on 7/14/25.
//

import Foundation
import SwiftData

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
