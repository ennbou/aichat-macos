import SwiftData
import Testing

@testable import Storage

final class SwiftDataManagerTests {
  var sut: SwiftDataManager!

  init() {
    // Setup in-memory configuration for testing
    sut = SwiftDataManager(inMemory: true)
  }

  deinit {
    sut = nil
  }

  @Test
  func testContextCreation() throws {
    // When
    let mainContext = sut.mainContext
    let newContext = sut.createNewContext()

    // Then
    try #require(mainContext != nil)
    try #require(newContext != nil)
  }

  @Test
  func testSaveAndFetch() throws {
    // Given
    let session = ChatSessionModel(title: "Test Session")
    let message = MessageModel(content: "Hello, world!", isUserMessage: true)

    // When
    sut.mainContext.insert(session)
    session.messages.append(message)
    sut.saveContext()

    // Then
    let fetchedSessions = try sut.fetch(ChatSessionModel.self)
    #expect(fetchedSessions.count == 1)
    #expect(fetchedSessions.first?.title == "Test Session")
    #expect(fetchedSessions.first?.messages.count == 1)
    #expect(fetchedSessions.first?.messages.first?.content == "Hello, world!")
  }

  @Test
  func testDelete() throws {
    // Given
    let session = ChatSessionModel(title: "Session to Delete")
    sut.mainContext.insert(session)
    sut.saveContext()

    // When
    sut.delete(session)
    sut.saveContext()

    // Then
    let fetchedSessions = try sut.fetch(ChatSessionModel.self)
    print(fetchedSessions.count)
    #expect(fetchedSessions.isEmpty)
  }
}
