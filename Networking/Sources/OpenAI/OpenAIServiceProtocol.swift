import Foundation

public protocol OpenAIServiceProtocol {
  func sendChatRequest(
    apiKey: String,
    request: OpenAIChatRequest,
    completion: @escaping (Result<OpenAIChatResponse, NetworkError>) -> Void
  )
  
  @available(macOS 12.0, *)
  func sendChatRequest(
    apiKey: String,
    request: OpenAIChatRequest
  ) async throws -> OpenAIChatResponse
  
  func createChatRequest(
    userQuery: String,
    model: String,
    systemPrompt: String?,
    temperature: Double,
    maxTokens: Int
  ) -> OpenAIChatRequest
}
