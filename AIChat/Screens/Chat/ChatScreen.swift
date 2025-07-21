import MarkdownUI
import Storage
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

struct ChatScreen: View {
  @Environment(\.chatScreenVM) var chatSecreenVM: ChatScreenVM
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
      chatSecreenVM.refreshSessions()
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
