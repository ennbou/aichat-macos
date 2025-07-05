//
//  Message.swift
//  AIChat
//
//  Created by Bouch on 6/25/25.
//

import Foundation
import Storage

// This file now contains utility methods for working with MessageModel from Storage module

extension MessageModel {
  // Factory method for creating messages in the AIChat app
  static func create(
    content: String,
    isUserMessage: Bool,
    chatSession: ChatSessionModel? = nil
  ) -> MessageModel {
    let message = MessageModel(
      content: content,
      isUserMessage: isUserMessage
    )
    return message
  }
}
