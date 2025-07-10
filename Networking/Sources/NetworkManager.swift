import Foundation

// MARK: - NetworkManager

public class NetworkManager {
  public static let shared = NetworkManager()

  public init() {}
  
  // This method allows us to override the URLSession in tests
  func getURLSession() -> URLSession {
    return URLSession.shared
  }

  public func request<T: Decodable>(
    url: URL,
    method: HTTPMethod = .get,
    headers: [String: String] = [:],
    body: Data? = nil,
    completion: @escaping (Result<T, NetworkError>) -> Void
  ) {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.httpBody = body

    headers.forEach { key, value in
      request.addValue(value, forHTTPHeaderField: key)
    }

    getURLSession()
      .dataTask(with: request) { data, response, error in
        if let error = error {
          completion(.failure(.requestFailed(error)))
          return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
          completion(.failure(.invalidResponse))
          return
        }

        guard (200...299).contains(httpResponse.statusCode) else {
          completion(.failure(.invalidStatusCode(httpResponse.statusCode)))
          return
        }

        guard let data = data else {
          completion(.failure(.noData))
          return
        }

        do {
          let decodedData = try JSONDecoder().decode(T.self, from: data)
          completion(.success(decodedData))
        } catch {
          completion(.failure(.decodingFailed(error)))
        }
      }
      .resume()
  }

}

public enum HTTPMethod: String {
  case get = "GET"
  case post = "POST"
  case put = "PUT"
  case delete = "DELETE"
  case patch = "PATCH"
}

public enum NetworkError: Error, Equatable {
  case requestFailed(Error)
  case invalidResponse
  case invalidStatusCode(Int)
  case noData
  case decodingFailed(Error)
  
  public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
    switch (lhs, rhs) {
    case (.invalidResponse, .invalidResponse):
      return true
    case (.invalidStatusCode(let lhsCode), .invalidStatusCode(let rhsCode)):
      return lhsCode == rhsCode
    case (.noData, .noData):
      return true
    // For error types that contain other errors, we cannot easily compare them
    // as Error doesn't conform to Equatable
    case (.requestFailed, .requestFailed),
         (.decodingFailed, .decodingFailed):
      return false
    default:
      return false
    }
  }

  public var localizedDescription: String {
    switch self {
    case .requestFailed(let error):
      return "Request failed: \(error.localizedDescription)"
    case .invalidResponse:
      return "Invalid response from server"
    case .invalidStatusCode(let code):
      return "Invalid status code: \(code)"
    case .noData:
      return "No data received from server"
    case .decodingFailed(let error):
      return "Failed to decode response: \(error.localizedDescription)"
    }
  }
}
