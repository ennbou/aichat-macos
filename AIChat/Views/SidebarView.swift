//
//  SidebarView.swift
//  AIChat
//
//  Created by Bouch on 6/25/25.
//

import AppKit
import SwiftData
import SwiftUI

struct SidebarView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \ChatSession.lastUpdatedAt, order: .reverse) private var chatSessions: [ChatSession]
  @Binding var selectedChatSession: ChatSession?

  @Environment(\.openWindow) private var openWindow

  @State private var sessionToRename: ChatSession?
  @State private var newSessionName: String = ""
  @State private var showRenameDialog: Bool = false

  var body: some View {
    VStack {
      List(selection: $selectedChatSession) {
        ForEach(chatSessions) { session in
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
    .alert("Rename Chat", isPresented: $showRenameDialog) {
      TextField("Chat Name", text: $newSessionName)

      Button("Cancel", role: .cancel) {
        showRenameDialog = false
      }

      Button("Rename") {
        if let session = sessionToRename, !newSessionName.isEmpty {
          session.title = newSessionName.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        showRenameDialog = false
      }
    } message: {
      Text("Enter a new name for this chat")
    }
  }

  private func formatDate(_ date: Date) -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .short
    return formatter.localizedString(for: date, relativeTo: Date())
  }

  private func createNewChat() {
    // Check if there's already an empty chat session
    if let emptySession = chatSessions.first(where: { $0.isEmpty }) {
      // Redirect to the existing empty session
      selectedChatSession = emptySession
    } else {
      // Create a new session
      let newSession = ChatSession(title: "Chat \(dateFormatter.string(from: Date()))")
      modelContext.insert(newSession)
      selectedChatSession = newSession
    }
  }

  private func deleteChatSessions(at offsets: IndexSet) {
    for index in offsets {
      let session = chatSessions[index]

      // Delete all messages first
      for message in session.messages {
        modelContext.delete(message)
      }

      // Then delete the session
      modelContext.delete(session)

      if selectedChatSession == session {
        selectedChatSession = chatSessions.first(where: { $0 != session })
      }
    }
  }

  private var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, HH:mm"
    return formatter
  }

  private func renameSession(_ session: ChatSession) {
    // Show the rename dialog
    sessionToRename = session
    newSessionName = session.title
    showRenameDialog = true
  }

  private func archiveSession(_ session: ChatSession) {
    // Toggle the archive state
    session.isArchived = !session.isArchived
  }

  private func deleteSession(_ session: ChatSession) {
    modelContext.delete(session)
    if selectedChatSession == session {
      selectedChatSession = chatSessions.first(where: { $0 != session })
    }
  }
}
