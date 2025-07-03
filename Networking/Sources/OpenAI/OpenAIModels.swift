import Foundation

// MARK: - OpenAI API Models

public struct OpenAIMessage: Codable {
  public var role: String
  public var content: String

  public init(role: String, content: String) {
    self.role = role
    self.content = content
  }
}

public struct OpenAIChatRequest: Codable {
  public var model: String
  public var messages: [OpenAIMessage]
  public var temperature: Double?
  public var max_tokens: Int?

  public init(
    model: String,
    messages: [OpenAIMessage],
    temperature: Double? = nil,
    max_tokens: Int? = nil
  ) {
    self.model = model
    self.messages = messages
    self.temperature = temperature
    self.max_tokens = max_tokens
  }
}

public struct OpenAIChoice: Codable {
  public var message: OpenAIMessage
  public var index: Int
  public var finish_reason: String?
}

public struct OpenAIChatResponse: Codable {
  public var id: String
  public var object: String
  public var created: Int
  public var model: String
  public var choices: [OpenAIChoice]

  public var firstMessage: OpenAIMessage? {
    return choices.first?.message
  }
}
