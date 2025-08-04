import Networking
import Storage
import SwiftUI

struct ChatView: View {
  @Environment(\.chatScreenVM) var chatScreenVM: ChatScreenVM

  @State private var messageText = ""
  @State private var isGeneratingResponse = false

  var body: some View {
    VStack(spacing: 0) {
      ScrollViewReader { scrollProxy in
        ScrollView {
          LazyVStack(spacing: 8) {
            if let messages = chatScreenVM.chatSession?.messages {
              ForEach(messages, id: \.id) { message in
                MessageBubble(message: message)
                  .id(message.id)
              }
            }
          }
          .padding(.horizontal)
          .padding(.top)
        }
        .onAppear {
          scrollToBottom(scrollProxy: scrollProxy)
        }
        .onChange(of: chatScreenVM.chatSession?.messages.count) { oldCount, newCount in
          if oldCount != newCount {
            scrollToBottom(scrollProxy: scrollProxy)
          }
        }
      }

      VStack(spacing: 8) {
        if isGeneratingResponse {
          HStack {
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
              .textFieldStyle(.plain)
              .font(.title3)
              .frame(maxWidth: .infinity)
              .onKeyPress(.return) {
                sendMessage()
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
    .navigationTitle(chatScreenVM.chatSession?.title ?? "Chat")
  }

  private func scrollToBottom(scrollProxy: ScrollViewProxy) {
    if let chatSession = chatScreenVM.chatSession, let lastMessage = chatSession.messages.last {
      withAnimation(.easeOut(duration: 0.3)) {
        scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
      }
    }
  }
  private func sendMessage() {
    let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmedMessage.isEmpty, let chatSession = chatScreenVM.chatSession else {
      return
    }

    Task { @MainActor in
      isGeneratingResponse = true
      await chatScreenVM.send(message: trimmedMessage, addTo: chatSession)
      messageText = ""
      isGeneratingResponse = false
    }
  }

  private func renameSession() {
    guard let chatSession = chatScreenVM.chatSession,
      let firstMessage = chatSession.messages.first(where: { $0.isUserMessage })
    else { return }
    let truncated = String(firstMessage.content.prefix(20))
    chatScreenVM.set(chatSession: chatSession, title: truncated)
  }
}
