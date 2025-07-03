import XCTest
@testable import Networking

final class OpenAIServiceTests: XCTestCase {
  func testCreateChatRequest() {
    let service = ServiceFactory.shared.makeOpenAIService()
    
    // Test with system prompt
    let requestWithSystem = service.createChatRequest(
      userQuery: "Hello, how are you?",
      model: "gpt-4",
      systemPrompt: "You are a helpful assistant",
      temperature: 0.7,
      maxTokens: 1000
    )
    
    XCTAssertEqual(requestWithSystem.model, "gpt-4")
    XCTAssertEqual(requestWithSystem.messages.count, 2)
    XCTAssertEqual(requestWithSystem.messages[0].role, "system")
    XCTAssertEqual(requestWithSystem.messages[0].content, "You are a helpful assistant")
    XCTAssertEqual(requestWithSystem.messages[1].role, "user")
    XCTAssertEqual(requestWithSystem.messages[1].content, "Hello, how are you?")
    XCTAssertEqual(requestWithSystem.temperature, 0.7)
    XCTAssertEqual(requestWithSystem.max_tokens, 1000)
    
    // Test without system prompt
    let requestWithoutSystem = service.createChatRequest(
      userQuery: "Hello, how are you?",
      model: "gpt-3.5-turbo",
      systemPrompt: nil,
      temperature: 0.5,
      maxTokens: 500
    )
    
    XCTAssertEqual(requestWithoutSystem.model, "gpt-3.5-turbo")
    XCTAssertEqual(requestWithoutSystem.messages.count, 1)
    XCTAssertEqual(requestWithoutSystem.messages[0].role, "user")
    XCTAssertEqual(requestWithoutSystem.messages[0].content, "Hello, how are you?")
    XCTAssertEqual(requestWithoutSystem.temperature, 0.5)
    XCTAssertEqual(requestWithoutSystem.max_tokens, 500)
  }
  
  func testOpenAIModels() {
    // Test Message
    let message = OpenAIMessage(role: "user", content: "Hello, how are you?")
    XCTAssertEqual(message.role, "user")
    XCTAssertEqual(message.content, "Hello, how are you?")
    
    // Test Response
    let choice = OpenAIChoice(
      message: OpenAIMessage(role: "assistant", content: "I'm doing well, thank you!"),
      index: 0,
      finish_reason: "stop"
    )
    
    let response = OpenAIChatResponse(
      id: "chatcmpl-123",
      object: "chat.completion",
      created: 1625097600,
      model: "gpt-4",
      choices: [choice]
    )
    
    XCTAssertEqual(response.id, "chatcmpl-123")
    XCTAssertEqual(response.model, "gpt-4")
    XCTAssertEqual(response.choices.count, 1)
    XCTAssertEqual(response.firstMessage?.role, "assistant")
    XCTAssertEqual(response.firstMessage?.content, "I'm doing well, thank you!")
  }
}
