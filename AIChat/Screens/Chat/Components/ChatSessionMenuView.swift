import Storage
import SwiftUI

struct ChatSessionMenuView: View {
  let session: ChatSessionModel
  let onShare: () -> Void
  let onRename: () -> Void
  let onArchive: () -> Void
  let onDelete: () -> Void

  var body: some View {
    Menu {
      Button(
        action: onShare,
        label: {
          Label("Share", systemImage: "square.and.arrow.up")
        }
      )

      Button(
        action: onRename,
        label: {
          Label("Rename", systemImage: "pencil")
        }
      )

      Button(
        action: onArchive,
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
        action: onDelete,
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
