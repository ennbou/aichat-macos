import Storage
import SwiftUI

struct SidebarView: View {
  @Environment(\.chatScreenVM) var chatScreenVM: ChatScreenVM
  @Environment(\.openWindow) private var openWindow

  @State private var sessionToRename: ChatSessionModel?
  @State private var newSessionName: String = ""
  @State private var showRenameDialog: Bool = false

  var body: some View {
    VStack {
      List(
        selection: Binding(
          get: { chatScreenVM.chatSession },
          set: { chatScreenVM.selectChatSession($0) }
        )
      ) {
        ForEach(chatScreenVM.allChatSessions) { session in
          NavigationLink(value: session) {
            HStack {
              VStack(alignment: .leading) {
                HStack {
                  if session.isArchived {
                    Image(systemName: "archivebox")
                      .font(.caption)
                      .foregroundColor(.secondary)
                  }

                  Text(session.title)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(session.isArchived ? .secondary : .primary)
                }
              }

              Spacer()

              Text("\(session.messages.count)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(6)
                .background(Color.gray.opacity(0.2))
                .clipShape(Circle())

              ChatSessionMenuView(
                session: session,
                onShare: {
                  print("")
                },
                onRename: { renameSession(session) },
                onArchive: { archiveSession(session) },
                onDelete: { deleteSession(session) }
              )
            }
          }
        }
      }

      Divider()

      Button(
        action: {
          openWindow(id: "settings")
        },
        label: {
          HStack {
            Image(systemName: "gear")
            Text("Settings")
            Spacer()
          }
          .padding()
        }
      )
      .buttonStyle(.plain)
      .background(Color.clear)
    }
    .navigationTitle("Chats")
    .toolbar {
      Button(action: createNewChat) {
        Label("New Chat", systemImage: "square.and.pencil")
      }
    }
    .renameSessionDialog(
      isPresented: $showRenameDialog,
      sessionName: $newSessionName,
      onRename: {
        if let session = sessionToRename, !newSessionName.isEmpty {
          let title = newSessionName.trimmingCharacters(in: .whitespacesAndNewlines)
          chatScreenVM.set(chatSession: session, title: title)
        }
      }
    )
  }

  private func createNewChat() {
    // Check if there's already an empty chat session
    if let emptySession = chatScreenVM.allChatSessions.first(where: { $0.isEmpty }) {
      // Redirect to the existing empty session
      chatScreenVM.selectChatSession(emptySession)
    } else {
      // Create a new session
      let newSession = chatScreenVM.createChatSession(
        title: "Chat \(dateFormatter.string(from: Date()))"
      )
      chatScreenVM.selectChatSession(newSession)
      chatScreenVM.refreshSessions()
    }
  }

  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, HH:mm"
    return formatter
  }

  private func renameSession(_ session: ChatSessionModel) {
    // Show the rename dialog
    sessionToRename = session
    newSessionName = session.title
    showRenameDialog = true
  }

  private func archiveSession(_ session: ChatSessionModel) {

  }

  private func deleteSession(_ chatSession: ChatSessionModel) {
    let wasSelected = self.chatScreenVM.chatSession == chatSession

    chatScreenVM.delete(chatSession: chatSession)
    chatScreenVM.refreshSessions()

    if wasSelected {
      chatScreenVM.selectChatSession(chatScreenVM.allChatSessions.first)
    }
  }
}
