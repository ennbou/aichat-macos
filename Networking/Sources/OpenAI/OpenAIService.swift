import Foundation

class OpenAIService: OpenAIServiceProtocol {
  private let networkManager: NetworkManager

  public init(networkManager: NetworkManager = NetworkManager.shared) {
    self.networkManager = networkManager
  }

  func sendChatRequest(
    apiKey: String,
    request: OpenAIChatRequest,
    completion: @escaping (Result<OpenAIChatResponse, NetworkError>) -> Void
  ) {
    guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
      completion(.failure(.invalidResponse))
      return
    }

    do {
      let requestData = try JSONEncoder().encode(request)

      let headers = [
        "Content-Type": "application/json",
        "Authorization": "Bearer \(apiKey)",
      ]

      self.networkManager.request(
        url: url,
        method: .post,
        headers: headers,
        body: requestData,
        completion: completion
      )
    } catch {
      completion(.failure(.requestFailed(error)))
    }
  }

  @available(macOS 12.0, *)
  func sendChatRequest(
    apiKey: String,
    request: OpenAIChatRequest
  ) async throws -> OpenAIChatResponse {
    return try await withCheckedThrowingContinuation { continuation in
      sendChatRequest(apiKey: apiKey, request: request) { result in
        switch result {
        case .success(let response):
          continuation.resume(returning: response)
        case .failure(let error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  func createChatRequest(
    userQuery: String,
    model: String = "gpt-3.5-turbo",
    systemPrompt: String? = nil,
    temperature: Double = 0.7,
    maxTokens: Int = 1000
  ) -> OpenAIChatRequest {
    var messages: [OpenAIMessage] = []

    if let systemPrompt = systemPrompt {
      messages.append(OpenAIMessage(role: "system", content: systemPrompt))
    }

    messages.append(OpenAIMessage(role: "user", content: userQuery))

    return OpenAIChatRequest(
      model: model,
      messages: messages,
      temperature: temperature,
      max_tokens: maxTokens
    )
  }
}
