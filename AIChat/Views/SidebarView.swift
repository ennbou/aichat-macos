import Storage
import SwiftUI

struct SidebarView: View {
  // Using our ChatRepository instead of direct SwiftData queries
  @Environment(\.chatScreenVM) var chatScreenVM: ChatScreenVM
  @Binding var selectedChatSession: ChatSessionModel?

  @Environment(\.openWindow) private var openWindow

  @State private var sessionToRename: ChatSessionModel?
  @State private var newSessionName: String = ""
  @State private var showRenameDialog: Bool = false

  var body: some View {
    VStack {
      List(selection: $selectedChatSession) {
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
              Menu {
                Button(
                  action: {
                    print("")
                  },
                  label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                  }
                )

                Button(
                  action: { renameSession(session) },
                  label: {
                    Label("Rename", systemImage: "pencil")
                  }
                )

                Button(
                  action: { archiveSession(session) },
                  label: {
                    Label(
                      session.isArchived ? "Unarchive" : "Archive",
                      systemImage: session.isArchived ? "archivebox.fill" : "archivebox"
                    )
                  }
                )

                Divider()

                Button(
                  role: .destructive,
                  action: { deleteSession(session) },
                  label: {
                    Label("Delete", systemImage: "trash")
                  }
                )
              } label: {
                Image(systemName: "ellipsis")
                  .foregroundColor(.gray)
                  .frame(width: 24, height: 24)
                  .contentShape(Rectangle())
              }
              .menuIndicator(.hidden)
              .buttonStyle(BorderlessButtonStyle())
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
    .onChange(of: selectedChatSession) { oldValue, newValue in
      if oldValue != newValue {
        chatScreenVM.refreshSessions()
      }
    }
    .alert("Rename Chat", isPresented: $showRenameDialog) {
      TextField("Chat Name", text: $newSessionName)

      Button("Cancel", role: .cancel) {
        showRenameDialog = false
      }

      Button("Rename") {
        if let session = sessionToRename, !newSessionName.isEmpty {
          let title = newSessionName.trimmingCharacters(in: .whitespacesAndNewlines)
          chatScreenVM.set(chatSession: session, title: title)
        }
        showRenameDialog = false
      }
    } message: {
      Text("Enter a new name for this chat")
    }
  }

  private func createNewChat() {
    // Check if there's already an empty chat session
    if let emptySession = chatScreenVM.allChatSessions.first(where: { $0.isEmpty }) {
      // Redirect to the existing empty session
      selectedChatSession = emptySession
    } else {
      // Create a new session
      let newSession = chatScreenVM.createChatSession(
        title: "Chat \(dateFormatter.string(from: Date()))"
      )
      selectedChatSession = newSession
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
    let wasSelected = selectedChatSession == chatSession

    chatScreenVM.delete(chatSession: chatSession)
    if wasSelected {
      selectedChatSession = chatScreenVM.allChatSessions.first
    }
  }
}
