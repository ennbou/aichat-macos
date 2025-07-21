import SwiftUI

struct RenameSessionDialogView: ViewModifier {
  @Binding var isPresented: Bool
  @Binding var sessionName: String
  let onRename: () -> Void

  func body(content: Content) -> some View {
    content
      .alert("Rename Chat", isPresented: $isPresented) {
        TextField("Chat Name", text: $sessionName)

        Button("Cancel", role: .cancel) {
          isPresented = false
        }

        Button("Rename") {
          onRename()
          isPresented = false
        }
      } message: {
        Text("Enter a new name for this chat")
      }
  }
}

extension View {
  func renameSessionDialog(
    isPresented: Binding<Bool>,
    sessionName: Binding<String>,
    onRename: @escaping () -> Void
  ) -> some View {
    modifier(
      RenameSessionDialogView(
        isPresented: isPresented,
        sessionName: sessionName,
        onRename: onRename
      )
    )
  }
}
