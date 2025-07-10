import Testing

@testable import Networking

final class ServiceFactoryTests {
  var serviceFactory: ServiceFactory!

  init() {
    serviceFactory = ServiceFactory.shared
  }

  deinit {
    serviceFactory = nil
  }

  @Test
  func testMakeOpenAIService() throws {
    // Get a service instance
    let service = serviceFactory.makeOpenAIService()

    // Verify it's not nil and is of the correct type
    try #require(service != nil)

    #expect(service is OpenAIService, "Service should be of type OpenAIService")
  }

  @Test
  func testMakeNewOpenAIService() throws {
    // Get two service instances
    let service1 = serviceFactory.makeNewOpenAIService()
    let service2 = serviceFactory.makeNewOpenAIService()

    // Verify they're not nil and are of the correct type
    try #require(service1 != nil)
    try #require(service2 != nil)
    #expect(service1 is OpenAIService, "Service should be of type OpenAIService")
    #expect(service2 is OpenAIService, "Service should be of type OpenAIService")

    // While they should be different instances, there's no clear way to verify this
    // as OpenAIService doesn't have any instance-specific identifiers.
    // In a real implementation, you might want to add a UUID property to verify this.
  }

  @Test
  func testSharedInstance() {
    // Verify shared instance exists and is a singleton
    let instance1 = ServiceFactory.shared
    let instance2 = ServiceFactory.shared

    // Same reference
    #expect(instance1 === instance2, "Shared instances should be the same reference")
  }
}
