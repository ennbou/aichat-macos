import MarkdownUI
import Storage
import SwiftUI

struct MessageBubble: View {
  let message: MessageModel

  var body: some View {
    HStack {
      if message.isUserMessage {
        Spacer(minLength: 60)
        Text(message.content)
          .textSelection(.enabled)
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(18)
      } else {
        Markdown(MarkdownContent(message.content))
          .textSelection(.enabled)
          .markdownTheme(
            .gitHub
              .text {
                FontSize(14)
              }
              .codeBlock { configuration in
                ScrollView(.horizontal) {
                  configuration.label
                    .fixedSize(horizontal: false, vertical: true)
                    .relativeLineSpacing(.em(0.225))
                    .markdownTextStyle {
                      FontFamilyVariant(.monospaced)
                      FontSize(.em(0.85))
                    }
                    .padding(16)
                }
                .background(.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .markdownMargin(top: 0, bottom: 16)
                .overlay(alignment: .topTrailing) {
                  CodeCopyButton(code: configuration.content)
                }
              }
          )
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
          .font(Font.system(size: 12, weight: .medium))
          .background(Color.white)
          .cornerRadius(18)
        Spacer(minLength: 60)
      }
    }
    .id(message.id)
  }
}
