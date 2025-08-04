import SwiftUI

private struct ChatScreenVmKey: EnvironmentKey {
  static let defaultValue = ChatScreenVM(
    chatSessinoRepostiry: ChatSessionLocalStorage.shared,
    allChatSessions: []
  )
}

extension EnvironmentValues {
  var chatScreenVM: ChatScreenVM {
    get { self[ChatScreenVmKey.self] }
    set { self[ChatScreenVmKey.self] = newValue }
  }
}
