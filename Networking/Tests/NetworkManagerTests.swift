import XCTest

@testable import Networking

final class NetworkManagerTests: XCTestCase {
  func testNetworkManager() {
    XCTAssertNotNil(NetworkManager.shared)
  }

  func testOpenAIModels() {
    // Test Message
    let message = OpenAIMessage(role: "user", content: "Hello, how are you?")
    XCTAssertEqual(message.role, "user")
    XCTAssertEqual(message.content, "Hello, how are you?")

    // Test Request
    let request = OpenAIChatRequest(
      model: "gpt-4",
      messages: [message],
      temperature: 0.7,
      max_tokens: 1000
    )
    XCTAssertEqual(request.model, "gpt-4")
    XCTAssertEqual(request.messages.count, 1)
    XCTAssertEqual(request.temperature, 0.7)
    XCTAssertEqual(request.max_tokens, 1000)
  }
}
