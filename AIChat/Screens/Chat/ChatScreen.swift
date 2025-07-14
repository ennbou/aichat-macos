//
//  ContentView.swift
//  AIChat
//
//  Created by Bouch on 6/25/25.
//

import MarkdownUI
import Storage
import SwiftUI

struct ChatScreen: View {
  // Using our ChatRepository instead of direct SwiftData queries
  @StateObject private var chatRepository = ChatLocalStorage.shared
  @State private var selectedChatSession: ChatSessionModel?

  var body: some View {
    NavigationSplitView {
      SidebarView(selectedChatSession: $selectedChatSession)
    } detail: {
      if let session = selectedChatSession {
        ChatView(chatSession: session)
          .id(session.id)  // Force view recreation when session changes
      } else {
        EmptyStateView()
      }
    }
    .onAppear {
      chatRepository.refreshSessions()
      ensureSelectedChatSession()
    }
    .onChange(of: selectedChatSession) { oldSession, newSession in
      handleSessionChange(oldSession: oldSession, newSession: newSession)
    }
  }

  private func ensureSelectedChatSession() {
    if selectedChatSession == nil {
      // Use the repository's already loaded sessions
      let sessions = chatRepository.chatSessions

      if let firstSession = sessions.first {
        selectedChatSession = firstSession
      } else {
        // Create a new session if none exist
        let newSession = chatRepository.createSession(title: "New Chat")
        selectedChatSession = newSession
      }
    }
  }

  private func handleSessionChange(oldSession: ChatSessionModel?, newSession: ChatSessionModel?) {
    if let oldSession = oldSession, oldSession.isEmpty, newSession != oldSession {
      //      let otherEmptySessions = chatRepository.chatSessions.filter {
      //        $0.isEmpty && $0.id != oldSession.id
      //      }
      //      if !otherEmptySessions.isEmpty, let newSession = newSession, !newSession.isEmpty {
      //        chatRepository.deleteSession(oldSession)
      //        chatRepository.refreshSessions()
      //      }
    }
  }
}

#Preview {
  ChatScreen()
}

struct CustomTextFieldStyle: TextFieldStyle {
  // swiftlint:disable:next identifier_name
  func _body(configuration: TextField<_Label>) -> some View {
    configuration
      .textFieldStyle(.plain)
      .font(.title3)
      .frame(maxWidth: .infinity)
      .textFieldStyle(.roundedBorder)
  }
}

struct SpinnerView: View {
  @State private var isRotating = false

  var body: some View {
    ZStack {
      Circle()
        .stroke(Color.gray.opacity(0.3), lineWidth: 2)
        .frame(width: 16, height: 16)

      Circle()
        .trim(from: 0, to: 0.7)
        .stroke(Color.blue, lineWidth: 2)
        .frame(width: 16, height: 16)
        .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
        .onAppear {
          withAnimation(Animation.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            self.isRotating = true
          }
        }
    }
  }
}
