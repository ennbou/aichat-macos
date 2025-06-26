//
//  ChatSession.swift
//  AIChat
//
//  Created by Bouch on 6/25/25.
//

import Foundation
import SwiftData

@Model
class ChatSession {
  var id: UUID
  var title: String
  var createdAt: Date
  var lastUpdatedAt: Date
  var isArchived: Bool = false
  @Relationship(deleteRule: .cascade, inverse: \Message.chatSession) var messages: [Message] = []

  init(title: String) {
    self.id = UUID()
    self.title = title
    self.createdAt = Date()
    self.lastUpdatedAt = Date()
    self.isArchived = false
    self.messages = []
  }

  func updateLastActivity() {
    self.lastUpdatedAt = Date()
  }

  var isEmpty: Bool {
    return messages.isEmpty
  }
}
