//
//  SidebarView.swift
//  AIChat
//
//  Created by Bouch on 6/25/25.
//

import Storage
import SwiftUI

struct SidebarView: View {
  // Using our ChatRepository instead of direct SwiftData queries
  @StateObject private var chatRepository = ChatRepository.shared
  @Binding var selectedChatSession: ChatSessionModel?

  @Environment(\.openWindow) private var openWindow

  @State private var sessionToRename: ChatSessionModel?
  @State private var newSessionName: String = ""
  @State private var showRenameDialog: Bool = false

  var body: some View {
    VStack {
      List(selection: $selectedChatSession) {
        ForEach(chatRepository.chatSessions) { session in
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
        .onDelete(perform: deleteChatSessions)
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
    .onAppear {
      chatRepository.refreshSessions()
    }
    .onChange(of: selectedChatSession) { oldValue, newValue in
      if oldValue != newValue {
        // Only refresh when selection actually changes
        chatRepository.refreshSessions()
      }
    }
    .alert("Rename Chat", isPresented: $showRenameDialog) {
      TextField("Chat Name", text: $newSessionName)

      Button("Cancel", role: .cancel) {
        showRenameDialog = false
      }

      Button("Rename") {
        if let session = sessionToRename, !newSessionName.isEmpty {
          session.title = newSessionName.trimmingCharacters(in: .whitespacesAndNewlines)
          chatRepository.updateSession(session)
        }
        showRenameDialog = false
      }
    } message: {
      Text("Enter a new name for this chat")
    }
  }

  private func createNewChat() {
    // Check if there's already an empty chat session
    if let emptySession = chatRepository.chatSessions.first(where: { $0.isEmpty }) {
      // Redirect to the existing empty session
      selectedChatSession = emptySession
    } else {
      // Create a new session
      let newSession = chatRepository.createSession(
        title: "Chat \(dateFormatter.string(from: Date()))"
      )
      selectedChatSession = newSession
    }
  }

  private func deleteChatSessions(at offsets: IndexSet) {
    for index in offsets {
      let session = chatRepository.chatSessions[index]

      // Delete the session using the repository
      chatRepository.deleteSession(session)

      if selectedChatSession == session {
        selectedChatSession = chatRepository.chatSessions.first(where: { $0 != session })
      }
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
    // Toggle the archive state
    session.isArchived = !session.isArchived
    chatRepository.updateSession(session)
  }

  private func deleteSession(_ session: ChatSessionModel) {
    // Store whether this session was selected before deletion
    let wasSelected = selectedChatSession == session

    chatRepository.deleteSession(session)

    // If the deleted session was selected, select another one
    if wasSelected {
      selectedChatSession = chatRepository.chatSessions.first
    }
  }
}
