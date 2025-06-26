//
//  Message.swift
//  AIChat
//
//  Created by Bouch on 6/25/25.
//

import Foundation
import SwiftData

@Model
class Message {
  var id: UUID
  var content: String
  var timestamp: Date
  var isFromUser: Bool

  // Relationship to chat session
  var chatSession: ChatSession?

  init(content: String, isFromUser: Bool, chatSession: ChatSession? = nil) {
    self.id = UUID()
    self.content = content
    self.timestamp = Date()
    self.isFromUser = isFromUser
    self.chatSession = chatSession
  }
}
