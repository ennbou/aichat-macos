import Foundation

public class ServiceFactory {
  public static let shared = ServiceFactory()

  private init() {}

  // Returns a shared instance of the OpenAI service
  public func makeOpenAIService() -> OpenAIServiceProtocol {
    return OpenAIService(networkManager: NetworkManager.shared)
  }

  // Returns a new instance of the OpenAI service
  public func makeNewOpenAIService() -> OpenAIServiceProtocol {
    return OpenAIService(networkManager: NetworkManager.shared)
  }
}
