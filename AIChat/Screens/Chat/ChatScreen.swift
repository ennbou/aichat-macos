import MarkdownUI
import Storage
import SwiftUI

private struct ChatRepositoryKey: EnvironmentKey {
  static let defaultValue: any ChatRepositoryProtocol = ChatLocalStorage.shared
}

extension EnvironmentValues {
  var chatRepository: any ChatRepositoryProtocol {
    get { self[ChatRepositoryKey.self] }
    set { self[ChatRepositoryKey.self] = newValue }
  }
}

struct ChatScreen: View {
  @Environment(\.chatRepository) var chatRepository: any ChatRepositoryProtocol
  @State private var selectedChatSession: ChatSessionModel?

  var body: some View {
    NavigationSplitView {
      SidebarView(selectedChatSession: $selectedChatSession)
    } detail: {
      if let session = selectedChatSession {
        ChatView(chatSession: session)
          .id(session.id)
      } else {
        EmptyStateView()
      }
    }
    .onAppear {
      chatRepository.refreshSessions()
      ensureSelectedChatSession()
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
