![Code Coverage](https://img.shields.io/badge/Code%20Coverage-70.50%25-brightgreen)

# Networking Module

The Networking module provides a robust API communication layer for the AIChat application. It handles API requests, response parsing, and error management in a clean, testable architecture.

![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![Platform](https://img.shields.io/badge/Platform-macOS%2014.0%2B-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- Generic network request handling
- Structured error handling and reporting
- OpenAI API integration
- Async/await support for modern Swift concurrency
- Comprehensive test coverage

## Architecture

The Networking module follows a clean layered architecture:

1. **NetworkManager**: Core networking functionality for making HTTP requests
2. **ServiceFactory**: Factory for creating service instances
3. **OpenAIService**: Implementation of the OpenAI API client
4. **Error Handling**: Structured approach to network errors

## Components

### NetworkManager

The `NetworkManager` provides core functionality for making HTTP requests with different methods (GET, POST, PUT, DELETE). It handles:

- Response parsing and decoding
- Error handling
- Request configuration

### ServiceFactory

The `ServiceFactory` follows the factory pattern to create service instances:

- Centralized service creation
- Dependency injection
- Configuration management

### OpenAIService

The `OpenAIService` provides a clean interface for interacting with OpenAI's APIs:

- Chat completions endpoint
- Request building
- Response parsing

### Models

- `OpenAIChatRequest`: Structure for chat completion requests
- `OpenAIChatResponse`: Structure for chat completion responses
- `OpenAIMessage`: Structure for individual messages
- `HTTPMethod`: HTTP methods supported by the API
- `NetworkError`: Error types that can occur during network operations

## Usage

### Making a basic request

```swift
let networkManager = NetworkManager.shared

struct Response: Decodable {
    let value: String
}

networkManager.request(
    url: URL(string: "https://api.example.com/endpoint")!,
    method: .get
) { (result: Result<Response, NetworkError>) in
    switch result {
    case .success(let response):
        print("Value: \(response.value)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

### Using OpenAI service

```swift
let service = ServiceFactory.shared.makeOpenAIService()
let request = service.createChatRequest(
    userQuery: "Hello, how are you?",
    model: "gpt-3.5-turbo",
    systemPrompt: "You are a helpful assistant"
)

service.sendChatRequest(apiKey: "YOUR_API_KEY", request: request) { result in
    switch result {
    case .success(let response):
        print("Response: \(response.firstMessage?.content ?? "")")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

### Using async/await (macOS 12.0+)

```swift
let service = ServiceFactory.shared.makeOpenAIService()
let request = service.createChatRequest(userQuery: "Tell me a joke")

do {
    let response = try await service.sendChatRequest(apiKey: "YOUR_API_KEY", request: request)
    print("Response: \(response.firstMessage?.content ?? "")")
} catch {
    print("Error: \(error.localizedDescription)")
}
```
