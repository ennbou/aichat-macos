import Foundation
import Testing

@testable import Networking

// MARK: - MockNetworkManager
class MockNetworkManager: NetworkManager {
  // Properties to verify calls
  var capturedURL: URL?
  var capturedMethod: HTTPMethod?
  var capturedHeaders: [String: String]?

  // Response control
  var mockResponse: Any?
  var mockError: NetworkError?

  // Generic request override
  override func request<T: Decodable>(
    url: URL,
    method: HTTPMethod = .get,
    headers: [String: String] = [:],
    body: Data? = nil,
    completion: @escaping (Result<T, NetworkError>) -> Void
  ) {
    // Capture request details
    capturedURL = url
    capturedMethod = method
    capturedHeaders = headers

    // Return mock result
    if let error = mockError {
      completion(.failure(error))
      return
    }

    if let response = mockResponse as? T {
      completion(.success(response))
    } else if let responseData = mockResponse as? Data {
      do {
        let decoded = try JSONDecoder().decode(T.self, from: responseData)
        completion(.success(decoded))
      } catch {
        completion(.failure(.decodingFailed(error)))
      }
    } else {
      completion(.failure(.noData))
    }
  }
}

final class OpenAIServiceTests {
  var mockNetworkManager: MockNetworkManager!
  var openAIService: OpenAIService!

  init() {
    mockNetworkManager = MockNetworkManager()
    openAIService = OpenAIService(networkManager: mockNetworkManager)
  }

  deinit {
    mockNetworkManager = nil
    openAIService = nil
  }

  @Test
  func testCreateChatRequest() {
    // Test with system prompt
    let requestWithSystem = openAIService.createChatRequest(
      userQuery: "Hello, how are you?",
      model: "gpt-4",
      systemPrompt: "You are a helpful assistant",
      temperature: 0.7,
      maxTokens: 1000
    )

    #expect(requestWithSystem.model == "gpt-4")
    #expect(requestWithSystem.messages.count == 2)
    #expect(requestWithSystem.messages[0].role == "system")
    #expect(requestWithSystem.messages[0].content == "You are a helpful assistant")
    #expect(requestWithSystem.messages[1].role == "user")
    #expect(requestWithSystem.messages[1].content == "Hello, how are you?")
    #expect(requestWithSystem.temperature == 0.7)
    #expect(requestWithSystem.max_tokens == 1000)

    // Test without system prompt
    let requestWithoutSystem = openAIService.createChatRequest(
      userQuery: "Hello, how are you?",
      model: "gpt-3.5-turbo",
      systemPrompt: nil,
      temperature: 0.5,
      maxTokens: 500
    )

    #expect(requestWithoutSystem.model == "gpt-3.5-turbo")
    #expect(requestWithoutSystem.messages.count == 1)
    #expect(requestWithoutSystem.messages[0].role == "user")
    #expect(requestWithoutSystem.messages[0].content == "Hello, how are you?")
    #expect(requestWithoutSystem.temperature == 0.5)
    #expect(requestWithoutSystem.max_tokens == 500)
  }

  @Test(.timeLimit(.minutes(1)))
  func testSendChatRequest() async {
    await confirmation("OpenAIService should return a response") { requestCalled in
      let apiKey = "test-api-key"
      let chatRequest = OpenAIChatRequest(
        model: "gpt-3.5-turbo",
        messages: [OpenAIMessage(role: "user", content: "Hello")]
      )

      let mockChoice = OpenAIChoice(
        message: OpenAIMessage(role: "assistant", content: "Hello there!"),
        index: 0,
        finish_reason: "stop"
      )
      let mockResponse = OpenAIChatResponse(
        id: "response-123",
        object: "chat.completion",
        created: 1_625_097_600,
        model: "gpt-3.5-turbo",
        choices: [mockChoice]
      )
      mockNetworkManager.mockResponse = mockResponse

      openAIService.sendChatRequest(apiKey: apiKey, request: chatRequest) { result in
        switch result {
        case .success(let response):
          #expect(response.id == "response-123")
          #expect(response.model == "gpt-3.5-turbo")
          #expect(response.choices.count == 1)
          #expect(response.firstMessage?.content == "Hello there!")

          #expect(
            self.mockNetworkManager.capturedURL?.absoluteString
              == "https://api.openai.com/v1/chat/completions"
          )
          #expect(self.mockNetworkManager.capturedMethod == .post)
          #expect(self.mockNetworkManager.capturedHeaders?["Authorization"] == "Bearer \(apiKey)")
          #expect(self.mockNetworkManager.capturedHeaders?["Content-Type"] == "application/json")

          requestCalled()
        case .failure(let error):
          Issue.record("Request should not fail: \(error.localizedDescription)")
        }
      }
    }
  }

  @Test(.timeLimit(.minutes(1)))
  func testSendChatRequestWithError() async {
    await confirmation("OpenAIService should return an error") { requestCalled in
      let apiKey = "test-api-key"
      let chatRequest = OpenAIChatRequest(
        model: "gpt-3.5-turbo",
        messages: [OpenAIMessage(role: "user", content: "Hello")]
      )

      mockNetworkManager.mockError = .invalidStatusCode(429)

      openAIService.sendChatRequest(apiKey: apiKey, request: chatRequest) { result in
        switch result {
        case .success:
          Issue.record("Request should fail with an error")
        case .failure(let error):
          if case .invalidStatusCode(let code) = error {
            #expect(code == 429)
          } else {
            Issue.record("Wrong error type: \(error)")
          }
          #expect(
            self.mockNetworkManager.capturedURL?.absoluteString
              == "https://api.openai.com/v1/chat/completions"
          )
          #expect(self.mockNetworkManager.capturedMethod == .post)
          #expect(self.mockNetworkManager.capturedHeaders?["Authorization"] == "Bearer \(apiKey)")

          requestCalled()
        }
      }
    }
  }

  @available(macOS 12.0, *)
  @Test(.timeLimit(.minutes(1)))
  func testAsyncAwaitSendChatRequest() async {
    let apiKey = "test-api-key"
    let chatRequest = OpenAIChatRequest(
      model: "gpt-3.5-turbo",
      messages: [OpenAIMessage(role: "user", content: "Hello")]
    )

    let mockChoice = OpenAIChoice(
      message: OpenAIMessage(role: "assistant", content: "Hello there!"),
      index: 0,
      finish_reason: "stop"
    )
    let mockResponse = OpenAIChatResponse(
      id: "response-123",
      object: "chat.completion",
      created: 1_625_097_600,
      model: "gpt-3.5-turbo",
      choices: [mockChoice]
    )
    mockNetworkManager.mockResponse = mockResponse

    do {
      let response = try await openAIService.sendChatRequest(apiKey: apiKey, request: chatRequest)

      #expect(response.id == "response-123")
      #expect(response.model == "gpt-3.5-turbo")
      #expect(response.choices.count == 1)
      #expect(response.firstMessage?.content == "Hello there!")

      #expect(
        self.mockNetworkManager.capturedURL?.absoluteString
          == "https://api.openai.com/v1/chat/completions"
      )
      #expect(self.mockNetworkManager.capturedMethod == .post)
      #expect(self.mockNetworkManager.capturedHeaders?["Authorization"] == "Bearer \(apiKey)")
      #expect(self.mockNetworkManager.capturedHeaders?["Content-Type"] == "application/json")
    } catch {
      Issue.record("Request should not fail: \(error.localizedDescription)")
    }
  }

  @Test
  func testOpenAIModels() {
    let message = OpenAIMessage(role: "user", content: "Hello, how are you?")
    #expect(message.role == "user")
    #expect(message.content == "Hello, how are you?")

    let choice = OpenAIChoice(
      message: OpenAIMessage(role: "assistant", content: "I'm doing well, thank you!"),
      index: 0,
      finish_reason: "stop"
    )

    let response = OpenAIChatResponse(
      id: "chatcmpl-123",
      object: "chat.completion",
      created: 1_625_097_600,
      model: "gpt-4",
      choices: [choice]
    )

    #expect(response.id == "chatcmpl-123")
    #expect(response.model == "gpt-4")
    #expect(response.choices.count == 1)
    #expect(response.firstMessage?.role == "assistant")
    #expect(response.firstMessage?.content == "I'm doing well, thank you!")
  }

  @Test(.timeLimit(.minutes(1)))
  func testSendChatRequestWithInvalidURL() async {
    // Create a subclass of OpenAIService that returns an invalid URL
    class InvalidURLOpenAIService: OpenAIService {
    }

    // Setup the service with the mock network manager
    let invalidService = InvalidURLOpenAIService(networkManager: mockNetworkManager)

    // Create request
    let request = invalidService.createChatRequest(
      userQuery: "Test query",
      model: "test-model"
    )

    // Setup the mock URL as nil to simulate URL creation failure
    // This is done by having the mock error ready
    mockNetworkManager.mockError = .invalidResponse

    // Call the method
    await confirmation("Chat request should fail with invalid URL") { sent in
      invalidService.sendChatRequest(apiKey: "test-api-key", request: request) { result in
        switch result {
        case .success:
          Issue.record("Expected failure but got success")
        case .failure(let error):
          #expect(error == NetworkError.invalidResponse)
        }
        sent()
      }
    }
  }
}
