//
//  ContentView.swift
//  AIChat
//
//  Created by Bouch on 6/25/25.
//

import MarkdownUI
import Networking
import Storage
import SwiftUI

struct ChatScreen: View {
  // Using our ChatRepository instead of direct SwiftData queries
  @StateObject private var chatRepository = ChatRepository.shared
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
      let otherEmptySessions = chatRepository.chatSessions.filter {
        $0.isEmpty && $0.id != oldSession.id
      }
      //      if !otherEmptySessions.isEmpty, let newSession = newSession, !newSession.isEmpty {
      //        chatRepository.deleteSession(oldSession)
      //        chatRepository.refreshSessions()
      //      }
    }
  }
}

struct ChatView: View {
  @StateObject private var chatRepository = ChatRepository.shared
  var chatSession: ChatSessionModel
  @State private var messageText = ""
  @State private var isGeneratingResponse = false
  @State private var messages: [MessageModel] = []

  init(chatSession: ChatSessionModel) {
    self.chatSession = chatSession
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

      VStack(spacing: 8) {
        // AI thinking indicator
        if isGeneratingResponse {
          HStack {
            // Using a Circle with overlay animation instead of ProgressView
            SpinnerView()
            Text("AI is thinking...")
              .font(.caption)
              .foregroundColor(.secondary)
            Spacer()
          }
          .padding(.horizontal)
          .padding(.bottom, 4)
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
              .disabled(isGeneratingResponse)

            Button(action: sendMessage) {
              Image(systemName: "paperplane.fill")
                .foregroundColor(
                  messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    || isGeneratingResponse ? .gray : .blue
                )
                .font(.system(size: 20))
                .background(Color.clear)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(
              messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || isGeneratingResponse
            )
            .padding(.trailing, 12)
            .padding(.bottom, 12)
          }
          .background(Color.gray.opacity(0.2))
          .cornerRadius(12)
        }
        .padding(.horizontal)
      }
      .padding(.vertical)
    }
    .navigationTitle(chatSession.title)
    .onAppear {
      loadMessages()
    }
    .onChange(of: chatSession.id) { oldValue, newValue in
      if oldValue != newValue {
        loadMessages()
      }
    }
  }

  private func loadMessages() {
    // Sort messages by timestamp
    messages = chatSession.messages.sorted(by: { $0.timestamp < $1.timestamp })
  }

  private func sendMessage() {
    let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedMessage.isEmpty else {
      return
    }

    // Use the repository to add the message
    let userMessage = chatRepository.addMessage(
      content: trimmedMessage,
      isUserMessage: true,
      to: chatSession
    )

    chatSession.updateLastActivity()
    chatRepository.updateSession(chatSession)

    // Refresh messages
    loadMessages()

    // Update session title with the first user message
    if messages.count <= 1 {
      renameSession()
    }

    // Clear the input field immediately
    messageText = ""

    // Get API key from settings
    let apiKey = UserDefaults.standard.string(forKey: "openaiApiKey") ?? ""

    // Show a placeholder message while waiting for OpenAI's response
    if apiKey.isEmpty {
      let errorMessage = chatRepository.addMessage(
        content: "Please set your OpenAI API key in the settings.",
        isUserMessage: false,
        to: chatSession
      )
      chatSession.updateLastActivity()
      chatRepository.updateSession(chatSession)
      loadMessages()
      return
    }

    // Set generating response state to true
    isGeneratingResponse = true

    // Create and send the OpenAI request
    let openAIService = ServiceFactory.shared.makeOpenAIService()
    let request = openAIService.createChatRequest(
      userQuery: trimmedMessage,
      model: "gpt-4o-mini-2024-07-18",
      systemPrompt: "You are a helpful AI assistant.",
      temperature: 0.7,
      maxTokens: 1000
    )

    openAIService.sendChatRequest(apiKey: apiKey, request: request) { result in
      DispatchQueue.main.async {
        // Set generating response state to false
        self.isGeneratingResponse = false

        switch result {
        case .success(let response):
          if let messageContent = response.firstMessage?.content {
            // Use repository to add AI response
            self.chatRepository.addMessage(
              content: messageContent,
              isUserMessage: false,
              to: self.chatSession
            )
          } else {
            // Handle empty response
            self.chatRepository.addMessage(
              content: "Received an empty response from the AI.",
              isUserMessage: false,
              to: self.chatSession
            )
          }
        case .failure(let error):
          // Handle error
          self.chatRepository.addMessage(
            content: "Error: \(error.localizedDescription)",
            isUserMessage: false,
            to: self.chatSession
          )
        }

        self.chatSession.updateLastActivity()
        self.chatRepository.updateSession(self.chatSession)
        // Refresh messages after receiving AI response
        self.loadMessages()
      }
    }
  }

  private func renameSession() {
    let firstMessage = messages.first(where: { $0.isUserMessage })?.content ?? ""
    let truncated = String(firstMessage.prefix(20))
    chatSession.title =
      truncated.isEmpty ? "Chat" : truncated + (truncated.count >= 20 ? "..." : "")
    chatRepository.updateSession(chatSession)
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
  let message: MessageModel

  var body: some View {
    HStack {
      if message.isUserMessage {
        Spacer(minLength: 60)
        Text(message.content)
          .textSelection(.enabled)
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(18)
      } else {
        Markdown(MarkdownContent(message.content))
          .textSelection(.enabled)
          .markdownTheme(
            .gitHub
              .text {
                FontSize(14)
              }
              .codeBlock { configuration in
                ScrollView(.horizontal) {
                  configuration.label
                    .fixedSize(horizontal: false, vertical: true)
                    .relativeLineSpacing(.em(0.225))
                    .markdownTextStyle {
                      FontFamilyVariant(.monospaced)
                      FontSize(.em(0.85))
                    }
                    .padding(16)
                }
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .markdownMargin(top: 0, bottom: 16)
                .overlay(alignment: .topTrailing) {
                  CodeCopyButton(code: configuration.content)
                }
              }
          )
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
          .font(Font.system(size: 12, weight: .medium))
          .background(Color.white)
          .cornerRadius(18)
        Spacer(minLength: 60)
      }
    }
    .id(message.id)
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
