//
//  SettingsView.swift
//  AIChat
//
//  Created by Bouch on 6/25/25.
//

import AppKit
import SwiftUI

struct SettingScreen: View {
  @AppStorage("openaiApiKey") private var openaiApiKey: String = ""
  @State private var isAPIKeyVisible: Bool = false
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    VStack {
      Form {
        Section {
          HStack {
            Image(systemName: "lock.shield")
              .foregroundColor(.secondary)
              .frame(width: 16, height: 16)

            if isAPIKeyVisible {
              TextField("OpenAI API Key", text: $openaiApiKey)
                .textFieldStyle(.roundedBorder)
            } else {
              SecureField("OpenAI API Key", text: $openaiApiKey)
                .textFieldStyle(.roundedBorder)
            }

            Button(
              action: {
                isAPIKeyVisible.toggle()
              },
              label: {
                Image(systemName: isAPIKeyVisible ? "eye.slash" : "eye")
                  .foregroundColor(.secondary)
                  .frame(width: 16, height: 16)
              }
            )
            .buttonStyle(.plain)
          }
        }
        Spacer()
      }
      .navigationTitle("Settings")
      .frame(minWidth: 400, minHeight: 500)
    }
    .padding(16)
    .onKeyPress(.escape) {
      dismiss()
      return .handled
    }
  }
}

#Preview {
  SettingScreen()
}
