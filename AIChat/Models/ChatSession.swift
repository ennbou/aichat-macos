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
  // Update the last activity time
  func updateLastActivity() {
    self.lastModifiedAt = Date()
  }

  // Check if the session has no messages
  var isEmpty: Bool {
    return messages.isEmpty
  }
}
