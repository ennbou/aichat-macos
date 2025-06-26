//
//  SettingsView.swift
//  AIChat
//
//  Created by Bouch on 6/25/25.
//

import AppKit
import SwiftUI

struct SettingScreen: View {
  @AppStorage("username") private var username: String = ""
  @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
  @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
  @AppStorage("fontSize") private var fontSize: Double = 14

  var body: some View {
    NavigationStack {
      Form {
        Section(header: Text("Profile")) {
          TextField("Username", text: $username)
        }

        Section(header: Text("Notifications")) {
          Toggle("Enable Notifications", isOn: $notificationsEnabled)
        }

        Section(header: Text("Appearance")) {
          Toggle("Dark Mode", isOn: $darkModeEnabled)

          VStack(alignment: .leading) {
            Text("Font Size: \(Int(fontSize))")
            Slider(value: $fontSize, in: 10...24, step: 1)
          }
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
