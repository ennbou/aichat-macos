# AIChat

AIChat is a macOS application built with SwiftUI that provides a chat interface for AI-powered conversations.

![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![Xcode](https://img.shields.io/badge/Xcode-15.0%2B-blue)
![Platform](https://img.shields.io/badge/Platform-macOS%2014.0%2B-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- Chat interface for conversations with AI
- Sidebar for navigation
- Settings screen to customize the application
- Multiple chat sessions support

## Project Structure

- `AIChat/`: Main application folder
  - `AIChatApp.swift`: Entry point for the application
  - `Models/`: Contains data models for the application
    - `ChatSession.swift`: Model for managing chat sessions
    - `Message.swift`: Model for chat messages
  - `Views/`: Contains UI components
    - `ChatScreen.swift`: Main chat interface
    - `SettingScreen.swift`: Settings configuration screen
    - `SidebarView.swift`: Navigation sidebar

## Requirements

- macOS
- Xcode 15.0+
- Swift 5.9+
- iOS 17.0+ / macOS 14.0+

## Installation

1. Clone this repository
2. Open `AIChat.xcodeproj` in Xcode
3. Build and run the application

## Development

### Tools
- SwiftLint for code style enforcement
- XCTest for unit and UI testing
- SwiftUI for UI development

### Best Practices
- MVVM Architecture
- Unit tests for business logic
- UI tests for critical user flows
- SwiftLint rules enforced

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Code Coverage

![Code Coverage](https://img.shields.io/badge/Code%20Coverage-0%25-brightgreen)

AIChat maintains a code coverage target of 80% for all production code. Code coverage reports are generated during the CI/CD pipeline runs.

## Author

Created by ENNBOU
