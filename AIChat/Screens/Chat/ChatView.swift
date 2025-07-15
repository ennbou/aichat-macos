import Networking
import Storage
import SwiftUI

struct ChatView: View {
  @StateObject private var chatRepository = ChatLocalStorage.shared
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
    _ = chatRepository.addMessage(
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
      _ = chatRepository.addMessage(
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
