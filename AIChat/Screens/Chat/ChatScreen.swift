import MarkdownUI
import Storage
import SwiftUI

struct ChatScreen: View {
  @Environment(\.chatScreenVM) var chatSecreenVM: ChatScreenVM

  var body: some View {
    NavigationSplitView {
      SidebarView()
    } detail: {
      if let session = chatSecreenVM.chatSession {
        ChatView()
          .id(session.id)
      } else {
        EmptyStateView()
      }
    }
    .onAppear {
      chatSecreenVM.loadSessions()
    }
  }
}

#Preview {
  ChatScreen()
}

struct CustomTextFieldStyle: TextFieldStyle {
  func _body(configuration: TextField<_Label>) -> some View {
    configuration
      .textFieldStyle(.plain)
      .font(.title3)
      .frame(maxWidth: .infinity)
      .textFieldStyle(.roundedBorder)
  }
}
