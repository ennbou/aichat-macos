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

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("API Settings")) {
          SecureField("OpenAI API Key", text: $openaiApiKey)
            .textFieldStyle(.roundedBorder)
        }
        Section(header: Text("About")) {
          HStack {
            Text("Version")
            Spacer()
            Text("1.0.0")
              .foregroundColor(.secondary)
          }
        }
      }
      .navigationTitle("Settings")
    }
    .frame(minWidth: 400, minHeight: 500)
  }
}

#Preview {
  SettingScreen()
}
