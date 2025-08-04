import Foundation
import Networking
import Observation
import Storage

@Observable
final class ChatScreenVM {
  let chatSessinoRepostiry: ChatSessionRepositoryProtocol
  let openAIService = ServiceFactory.shared.makeOpenAIService()

  var chatSession: ChatSessionModel?
  var allChatSessions: [ChatSessionModel]

  init(
    chatSessinoRepostiry: ChatSessionRepositoryProtocol,
    chatSession: ChatSessionModel? = nil,
    allChatSessions: [ChatSessionModel]
  ) {
    self.chatSessinoRepostiry = chatSessinoRepostiry
    self.chatSession = chatSession
    self.allChatSessions = allChatSessions
  }

  func createChatSession(title: String) -> ChatSessionModel {
    let chatSession = ChatSessionModel(title: title)
    chatSessinoRepostiry.create(chatSession: chatSession)
    return chatSession
  }

  func loadSessions() {
    let previousSessionId = chatSession?.id
    allChatSessions = chatSessinoRepostiry.getAllSessions(sortBy: nil)

    if let previousId = previousSessionId,
      let existingSession = allChatSessions.first(where: { $0.id == previousId }) {
      chatSession = existingSession
    } else if chatSession == nil {
      chatSession = allChatSessions.first
    }
  }

  func selectChatSession(_ session: ChatSessionModel?) {
    chatSession = session
  }

  func reloadSessionData() {
    guard let currentSessionId = chatSession?.id else { return }

    if let reloadedSession = chatSessinoRepostiry.getSessionBy(id: currentSessionId) {
      chatSession = reloadedSession
    }
  }

  @discardableResult
  func addMessage(
    content: String,
    isUserMessage: Bool,
    to chatSession: ChatSessionModel
  ) -> MessageModel {
    let message = MessageModel(
      content: content,
      isUserMessage: isUserMessage,
      chatSession: chatSession
    )
    chatSession.messages.append(message)
    chatSession.updateLastActivity()
    chatSessinoRepostiry.update(chatSession: chatSession)

    reloadSessionData()

    return message
  }

  func set(chatSession: ChatSessionModel, title: String) {
    chatSession.title = title
    chatSessinoRepostiry.update(chatSession: chatSession)
  }

  func createChatsession(title: String) -> ChatSessionModel {
    let chatSession = ChatSessionModel(title: title)
    chatSessinoRepostiry.create(chatSession: chatSession)
    return chatSession
  }

  func delete(chatSession: ChatSessionModel) {
    _ = chatSessinoRepostiry.delete(chatSession: chatSession)
  }

  func send(message: String, addTo chatSession: ChatSessionModel) async {
    let newMessage = addMessage(
      content: message,
      isUserMessage: true,
      to: chatSession
    )

    chatSession.messages.append(newMessage)

    let apiKey = UserDefaults.standard.string(forKey: "openaiApiKey") ?? ""

    if apiKey.isEmpty {
      addMessage(
        content: "Please set your OpenAI API key in the settings.",
        isUserMessage: false,
        to: chatSession
      )
    } else {
      let request = openAIService.createChatRequest(
        userQuery: message,
        model: "gpt-4o-mini-2024-07-18",
        systemPrompt: "You are a helpful AI assistant.",
        temperature: 0.7,
        maxTokens: 1000
      )

      do {
        let response = try await openAIService.sendChatRequest(apiKey: apiKey, request: request)
        if let messageContent = response.firstMessage?.content {
          addMessage(
            content: messageContent,
            isUserMessage: false,
            to: chatSession
          )
        } else {
          addMessage(
            content: "Received an empty response from the AI.",
            isUserMessage: false,
            to: chatSession
          )
        }
      } catch {
        addMessage(
          content: "Error: \(error.localizedDescription)",
          isUserMessage: false,
          to: chatSession
        )
      }
    }
  }
}
