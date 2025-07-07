import AppKit
import SwiftUI

struct CodeCopyButton: View {
  let code: String
  @State private var isHovering = false
  @State private var isCopied = false
  @State private var animationTrigger = false

  var body: some View {
    Button(action: {
      // Copy code to clipboard
      NSPasteboard.general.clearContents()
      NSPasteboard.general.setString(code, forType: .string)

      // Trigger animation
      withAnimation {
        isCopied = true
        animationTrigger = true
      }

      // Reset after delay
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        withAnimation(.easeInOut(duration: 0.3)) {
          isCopied = false
        }
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
        withAnimation(.easeInOut(duration: 0.3)) {
          animationTrigger = false
        }
      }
    }) {
      HStack(spacing: 4) {
        // Show checkmark when copied, otherwise show copy icon
        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
          .font(.system(size: 12))
          .symbolEffect(.bounce, value: animationTrigger)

        // Optionally show text when hovering or after copy
        if isHovering || isCopied {
          Text(isCopied ? "Copied!" : "Copy")
            .font(.caption)
            .transition(.opacity.combined(with: .move(edge: .trailing)))
        }
      }
      .padding(.horizontal, 8)
      .padding(.vertical, 6)
      .foregroundColor(isCopied ? .green : .secondary)
      .background(
        RoundedRectangle(cornerRadius: 6)
          .fill(isHovering || isCopied ? Color.secondary.opacity(0.15) : Color.clear)
          .overlay(
            RoundedRectangle(cornerRadius: 6)
              .stroke(
                isCopied ? Color.green.opacity(0.3) : Color.secondary.opacity(0.2),
                lineWidth: isCopied ? 1.5 : 1
              )
              .opacity(isHovering || isCopied ? 1 : 0)
          )
      )
      .opacity(isHovering ? 1 : 0.7)
      .scaleEffect(isCopied ? 1.05 : 1.0)
    }
    .buttonStyle(.plain)
    .padding(6)
    .onHover { hovering in
      withAnimation(.easeInOut(duration: 0.2)) {
        isHovering = hovering
      }
    }
  }
}

#Preview {
  CodeCopyButton(code: "print(\"Hello, world!\")")
    .padding()
    .background(Color.gray.opacity(0.1))
}
