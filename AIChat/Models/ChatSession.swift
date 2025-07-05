//
//  ChatSession.swift
//  AIChat
//
//  Created by Bouch on 6/25/25.
//

import Foundation
import Storage

// This file now contains utility methods for working with ChatSessionModel from Storage module

extension ChatSessionModel {
  // Helper to access lastModifiedAt with the old name for transition purposes
  var lastUpdatedAt: Date {
    return lastModifiedAt
  }

  // Update the last activity time
  func updateLastActivity() {
    self.lastModifiedAt = Date()
  }

  // Check if the session has no messages
  var isEmpty: Bool {
    return messages.isEmpty
  }

  // Factory method for creating chat sessions in the AIChat app
  static func create(title: String) -> ChatSessionModel {
    return ChatSessionModel(
      title: title,
      createdAt: Date(),
      lastModifiedAt: Date(),
      isArchived: false,
      messages: []
    )
  }
}
