import Testing
import Foundation

@testable import Networking

// MARK: - MockURLProtocol for testing network requests
class MockURLProtocol: URLProtocol {
        static var mockResponses = [URL: (data: Data?, response: HTTPURLResponse?, error: Error?)]()
    
    // Register a mock response for a URL
    static func mockHTTPResponse(for url: URL, data: Data?, statusCode: Int, error: Error? = nil) {
        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )
        mockResponses[url] = (data, response, error)
    }
    
        static func reset() {
        mockResponses.removeAll()
    }
    
        override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
        override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }
        
        if let (data, response, error) = MockURLProtocol.mockResponses[url] {
                        if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
                        if let response = response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
                        if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
        }
        
                client?.urlProtocolDidFinishLoading(self)
    }
    
    // Required but we don't need to do anything here
    override func stopLoading() {}
}

final class NetworkManagerTests {
    var networkManager: NetworkManager!
    var session: URLSession!
    
    init() {
                let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
        
                class TestNetworkManager: NetworkManager {
            var session: URLSession
            
            init(session: URLSession) {
                self.session = session
                super.init()
            }
            
            override func getURLSession() -> URLSession {
                return session
            }
        }
        
        networkManager = TestNetworkManager(session: session)
    }
    
    deinit {
        MockURLProtocol.reset()
        session = nil
        networkManager = nil
    }

    @Test func testNetworkManager() throws {
        try #require(NetworkManager.shared != nil)
    }
    
    @Test(.timeLimit(.minutes(1)))
    func testRequestSuccess() async {
        await confirmation("Request should succeed") { requestCalled in
            let testURL = URL(string: "https://api.example.com/test")!
            let testData = """
            {
                "id": "123",
                "name": "Test Name"
            }
            """.data(using: .utf8)!
            
            struct TestResponse: Decodable {
                let id: String
                let name: String
            }
            
            MockURLProtocol.mockHTTPResponse(for: testURL, data: testData, statusCode: 200)
            
            networkManager.request(url: testURL) { (result: Result<TestResponse, NetworkError>) in
                switch result {
                case .success(let response):
                    #expect(response.id == "123")
                    #expect(response.name == "Test Name")
                    requestCalled()
                case .failure(let error):
                    Issue.record("Request should not fail: \(error.localizedDescription)")
                }
            }
            sleep(1)
        }
        
    }
    
    @Test(.timeLimit(.minutes(1)))
    func testRequestFailureInvalidStatusCode() async {
        await confirmation("Request should fail with invalid status code") { requestCalled in

            let testURL = URL(string: "https://api.example.com/test")!
            let testData = "Error message".data(using: .utf8)!
            
            struct TestResponse: Decodable {
                let id: String
            }
            
            MockURLProtocol.mockHTTPResponse(for: testURL, data: testData, statusCode: 401)
            
            networkManager.request(url: testURL) { (result: Result<TestResponse, NetworkError>) in
                switch result {
                case .success:
                    Issue.record("Request should fail with invalid status code")
                case .failure(let error):
                    if case .invalidStatusCode(let code) = error {
                        #expect(code == 401)
                        requestCalled()
                    } else {
                        Issue.record("Wrong error type: \(error)")
                    }
                }
            }
            sleep(1)
        }
    }
    
    @Test(.timeLimit(.minutes(1)))
    func testRequestFailureNetworkError() async {
        await confirmation("Request should fail with network error") { requestCalled in
            let testURL = URL(string: "https://api.example.com/test")!
            let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet, userInfo: nil)
            
            struct TestResponse: Decodable {
                let id: String
            }
            
            MockURLProtocol.mockHTTPResponse(for: testURL, data: nil, statusCode: 200, error: error)
            
            networkManager.request(url: testURL) { (result: Result<TestResponse, NetworkError>) in
                switch result {
                case .success:
                    Issue.record("Request should fail with network error")
                case .failure(let networkError):
                    if case .requestFailed = networkError {
                        requestCalled()
                    } else {
                        Issue.record("Wrong error type: \(networkError)")
                    }
                }
            }
            sleep(1)
        }
    }
    
    @Test(.timeLimit(.minutes(1)))
    func testRequestFailureDecodingError() async {
        await confirmation("Request should fail with decoding error") { requestCalled in
            let testURL = URL(string: "https://api.example.com/test")!
            let invalidData = """
            {
                "invalid_field": "value"
            }
            """.data(using: .utf8)!
            
            struct TestResponse: Decodable {
                let id: String             }
            
            MockURLProtocol.mockHTTPResponse(for: testURL, data: invalidData, statusCode: 200)
            
                        networkManager.request(url: testURL) { (result: Result<TestResponse, NetworkError>) in
                switch result {
                case .success:
                    Issue.record("Request should fail with decoding error")
                case .failure(let error):
                    if case .decodingFailed = error {
                        requestCalled()
                    } else {
                        Issue.record("Wrong error type: \(error)")
                    }
                }
            }
            sleep(1)
        }
    }
  
    @Test(.timeLimit(.minutes(1)))
    func testOpenAIModels() async {
                let message = OpenAIMessage(role: "user", content: "Hello, how are you?")
        #expect(message.role == "user")
        #expect(message.content == "Hello, how are you?")
        
                let request = OpenAIChatRequest(
            model: "gpt-4",
            messages: [message],
            temperature: 0.7,
            max_tokens: 1000
        )
        #expect(request.model == "gpt-4")
        #expect(request.messages.count == 1)
        #expect(request.temperature == 0.7)
        #expect(request.max_tokens == 1000)
    }
    
    @Test(.timeLimit(.minutes(1)))
    func testRequestWithDifferentHTTPMethods() async {
                let url = URL(string: "https://example.com/api")!
        
                let methods: [HTTPMethod] = [.get, .post, .put, .delete]
        
        for method in methods {
                        await confirmation("Should make a successful \(method) request"){ requestCalled in
                let responseData = """
                {
                    "success": true,
                    "method": "\(method.rawValue)"
                }
                """.data(using: .utf8)!
                
                MockURLProtocol.mockHTTPResponse(for: url, data: responseData, statusCode: 200)
                
                struct TestResponse: Decodable {
                    let success: Bool
                    let method: String
                }
                
                networkManager.request(
                    url: url,
                    method: method,
                    headers: ["Content-Type": "application/json"],
                    body: nil
                ) { (result: Result<TestResponse, NetworkError>) in
                    switch result {
                    case .success(let response):
                        #expect(response.success)
                        #expect(response.method == method.rawValue)
                    case .failure(let error):
                        Issue.record("Request should succeed but failed with error: \(error.localizedDescription)")
                    }
                    requestCalled()
                }
                sleep(1)
            }
            MockURLProtocol.reset()
        }
    }
    
    @Test(.timeLimit(.minutes(1)))
    func testRequestWithHeaders() async {
        let url = URL(string: "https://example.com/api")!
        
        let customHeaders = [
            "X-API-Key": "test-api-key",
            "X-Custom-Header": "test-value",
            "Content-Type": "application/json"
        ]
        
        await confirmation("Should make a successful request with headers"){ requestCalled in
            let responseData = """
            {
                "success": true
            }
            """.data(using: .utf8)!
            
            MockURLProtocol.mockHTTPResponse(for: url, data: responseData, statusCode: 200)
            
            struct TestResponse: Decodable {
                let success: Bool
            }

            networkManager.request(
                url: url,
                method: .get,
                headers: customHeaders
            ) { (result: Result<TestResponse, NetworkError>) in
                switch result {
                case .success(let response):
                    #expect(response.success)
                case .failure(let error):
                    Issue.record("Request should succeed but failed with error: \(error.localizedDescription)")
                }
                requestCalled()
            }
            sleep(1)
        }
        
    }
}
