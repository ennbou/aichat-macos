//
//  EmptyChat.swift
//  AIChat
//
//  Created by Bouch on 7/14/25.
//

import SwiftUI

struct EmptyStateView: View {
  var body: some View {
    VStack(spacing: 20) {
      Image(systemName: "bubble.left.and.bubble.right")
        .font(.system(size: 70))
        .foregroundColor(.gray.opacity(0.5))

      Text("Select a chat or create a new one")
        .font(.title2)
        .foregroundColor(.secondary)
    }
  }
}
