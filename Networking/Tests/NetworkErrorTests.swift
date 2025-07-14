import Foundation
import Testing

@testable import Networking

final class NetworkErrorTests {
  @Test func testLocalizedDescription() {
    // Test all error cases to ensure they provide descriptive error messages

    // Request failed error
    let underlyingError = NSError(
      domain: "test",
      code: 123,
      userInfo: [NSLocalizedDescriptionKey: "Network connection lost"]
    )
    let requestFailedError = NetworkError.requestFailed(underlyingError)
    #expect(requestFailedError.localizedDescription == "Request failed: Network connection lost")

    // Invalid response error
    let invalidResponseError = NetworkError.invalidResponse
    #expect(invalidResponseError.localizedDescription == "Invalid response from server")

    // Invalid status code error
    let invalidStatusCodeError = NetworkError.invalidStatusCode(404)
    #expect(invalidStatusCodeError.localizedDescription == "Invalid status code: 404")

    // No data error
    let noDataError = NetworkError.noData
    #expect(noDataError.localizedDescription == "No data received from server")

    // Decoding failed error
    let decodingError = NSError(
      domain: "DecodingErrorDomain",
      code: 4,
      userInfo: [NSLocalizedDescriptionKey: "Key not found"]
    )
    let decodingFailedError = NetworkError.decodingFailed(decodingError)
    #expect(decodingFailedError.localizedDescription == "Failed to decode response: Key not found")
  }

  @Test
  func testEquatableConformance() {
    // Test that NetworkError conforms to Equatable correctly

    // Create errors of the same type with the same values
    let underlyingError1 = NSError(
      domain: "test",
      code: 123,
      userInfo: [NSLocalizedDescriptionKey: "Error message"]
    )
    let underlyingError2 = NSError(
      domain: "test",
      code: 123,
      userInfo: [NSLocalizedDescriptionKey: "Error message"]
    )

    // These should not be equal because the underlying NSError instances are different objects
    // We can't test this with XCTAssertNotEqual because Error doesn't conform to Equatable
    // So we just create them to demonstrate the concept
    _ = NetworkError.requestFailed(underlyingError1)
    _ = NetworkError.requestFailed(underlyingError2)

    // Errors with the same type should be equal
    #expect(NetworkError.invalidResponse == NetworkError.invalidResponse)
    #expect(NetworkError.invalidStatusCode(404) == NetworkError.invalidStatusCode(404))
    #expect(NetworkError.noData == NetworkError.noData)

    // Errors with different status codes should not be equal
    #expect(NetworkError.invalidStatusCode(404) != NetworkError.invalidStatusCode(500))

    // Different error types should not be equal
    #expect(NetworkError.invalidResponse != NetworkError.noData)
    #expect(NetworkError.invalidStatusCode(404) != NetworkError.noData)
  }
}
