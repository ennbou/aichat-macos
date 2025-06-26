//
//  ContentView.swift
//  AIChat
//
//  Created by Bouch on 6/25/25.
//

import SwiftData
import SwiftUI

struct ChatScreen: View {
  @Environment(\.modelContext) private var modelContext
  @State private var selectedChatSession: ChatSession?
  @Query private var allChatSessions: [ChatSession]

  var body: some View {
    NavigationSplitView {
      SidebarView(selectedChatSession: $selectedChatSession)
    } detail: {
      if let session = selectedChatSession {
        ChatView(chatSession: session)
      } else {
        EmptyStateView()
      }
    }
    .onAppear {
      ensureSelectedChatSession()
    }
    .onChange(of: selectedChatSession) { oldSession, newSession in
      handleSessionChange(oldSession: oldSession, newSession: newSession)
    }
  }

  private func ensureSelectedChatSession() {
    if selectedChatSession == nil {
      let descriptor = FetchDescriptor<ChatSession>(sortBy: [
        SortDescriptor(\.lastUpdatedAt, order: .reverse)
      ])
      do {
        let sessions = try modelContext.fetch(descriptor)
        if let firstSession = sessions.first {
          selectedChatSession = firstSession
        } else {
          let newSession = ChatSession(title: "New Chat")
          modelContext.insert(newSession)
          selectedChatSession = newSession
        }
      } catch {
        print("Error fetching chat sessions: \(error)")
        let newSession = ChatSession(title: "New Chat")
        modelContext.insert(newSession)
        selectedChatSession = newSession
      }
    }
  }

  private func handleSessionChange(oldSession: ChatSession?, newSession: ChatSession?) {
    if let oldSession = oldSession, oldSession.isEmpty, newSession != oldSession {
      let otherEmptySessions = allChatSessions.filter { $0.isEmpty && $0.id != oldSession.id }
      if !otherEmptySessions.isEmpty, let newSession = newSession, !newSession.isEmpty {
        modelContext.delete(oldSession)
      }
    }
  }
}

struct ChatView: View {
  @Environment(\.modelContext) private var modelContext
  var chatSession: ChatSession
  @State private var messageText = ""
  @Query private var messages: [Message]

  init(chatSession: ChatSession) {
    self.chatSession = chatSession
    let id = chatSession.id
    let predicate = #Predicate<Message> { message in
      message.chatSession?.id == id
    }
    let descriptor = FetchDescriptor<Message>(
      predicate: predicate,
      sortBy: [SortDescriptor(\.timestamp, order: .forward)]
    )
    self._messages = Query(descriptor)
  }

  var body: some View {
    VStack(spacing: 0) {
      ScrollViewReader { scrollProxy in
        ScrollView {
          LazyVStack(spacing: 8) {
            ForEach(messages, id: \.id) { message in
              MessageBubble(message: message)
            }
          }
          .padding(.horizontal)
          .padding(.top)
        }
        .onChange(of: messages.count) { _, _ in
          if let lastMessage = messages.last {
            withAnimation(.easeOut(duration: 0.3)) {
              scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
          }
        }
      }

      HStack(alignment: .bottom, spacing: 0) {
        HStack(alignment: .bottom, spacing: 8) {
          TextField("Type a message...", text: $messageText, axis: .vertical)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .lineLimit(1...6)
            .font(.body)
            .textFieldStyle(CustomTextFieldStyle())
            .onKeyPress(.return) {
              messageText += "\n"
              return .handled
            }

          Button(action: sendMessage) {
            Image(systemName: "paperplane.fill")
              .foregroundColor(
                messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue
              )
              .font(.system(size: 20))
              .background(Color.clear)
          }
          .buttonStyle(PlainButtonStyle())
          .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
          .padding(.trailing, 12)
          .padding(.bottom, 12)
        }
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
      }
      .padding()
    }
    .navigationTitle(chatSession.title)
  }

  private func sendMessage() {
    let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedMessage.isEmpty else {
      return
    }

    let userMessage = Message(content: trimmedMessage, isFromUser: true, chatSession: chatSession)
    modelContext.insert(userMessage)

    chatSession.updateLastActivity()

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      let aiMessage = Message(
        content: generateAIResponse(to: trimmedMessage),
        isFromUser: false,
        chatSession: self.chatSession
      )
      modelContext.insert(aiMessage)
      chatSession.updateLastActivity()
    }

    messageText = ""
  }

  private func generateAIResponse(to message: String) -> String {
    let responses = [
      "That's interesting! Tell me more.",
      "I understand what you're saying.",
      "Thanks for sharing that with me.",
      "How can I help you with that?",
      "That sounds great!",
      "I'm here to help you with any questions.",
      "What would you like to know more about?",
    ]
    return responses.randomElement() ?? "I'm processing your message..."
  }

  private func renameSession() {
    let firstMessage = messages.first(where: { $0.isFromUser })?.content ?? ""
    let truncated = String(firstMessage.prefix(20))
    chatSession.title =
      truncated.isEmpty ? "Chat" : truncated + (truncated.count >= 20 ? "..." : "")
  }
}

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

struct MessageBubble: View {
  let message: Message

  var body: some View {
    HStack {
      if message.isFromUser {
        Spacer(minLength: 60)
        Text(message.content)
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(18)
      } else {
        Text(message.content)
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
          .background(Color.gray.opacity(0.3))
          .foregroundColor(.primary)
          .cornerRadius(18)
        Spacer(minLength: 60)
      }
    }
    .id(message.id)
  }
}

#Preview {
  ChatScreen()
    .modelContainer(for: Message.self, inMemory: true)
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
