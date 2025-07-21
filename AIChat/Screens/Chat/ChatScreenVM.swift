//
//  ChatScreenVM.swift
//  AIChat
//
//  Created by Bouch on 7/21/25.
//

import Observation
import Storage

@Observable
final class ChatScreenVM {

    let chatSessinoRepostiry: ChatSessionRepositoryProtocol
    
    var chatSession: ChatSessionModel?
    var allChatSessions: [ChatSessionModel]

    init(chatSessinoRepostiry: ChatSessionRepositoryProtocol, chatSession: ChatSessionModel? = nil, allChatSessions: [ChatSessionModel]) {
        self.chatSessinoRepostiry = chatSessinoRepostiry
        self.chatSession = chatSession
        self.allChatSessions = allChatSessions
    }
    
    func createChatSession(title: String) -> ChatSessionModel {
        let chatSession = ChatSessionModel(title: title)
        chatSessinoRepostiry.create(chatSession: chatSession)
        return chatSession
    }
    
    func refreshSessions() {
        allChatSessions = chatSessinoRepostiry.getAllSessions(sortBy: nil)
        chatSession = allChatSessions.first
    }

    @discardableResult
    func addMessage(
      content: String,
      isUserMessage: Bool,
      to chatSession: ChatSessionModel
    ) -> MessageModel {
      let message = MessageModel(content: content, isUserMessage: isUserMessage, chatSession: chatSession)
        chatSession.messages.append(message)
        chatSession.updateLastActivity()
        chatSessinoRepostiry.update(chatSession: chatSession)
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
}
