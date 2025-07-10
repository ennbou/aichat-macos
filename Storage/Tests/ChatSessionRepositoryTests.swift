import Foundation
import Testing

@testable import Storage

final class ChatSessionRepositoryTests {
  var sut: ChatSessionRepository!
  var swiftDataManager: SwiftDataManager!

  init() {
    // Create an in-memory SwiftDataManager for testing
    swiftDataManager = createInMemorySwiftDataManager()
    sut = ChatSessionRepository(swiftDataManager: swiftDataManager)
  }

  deinit {
    // Clean up after each test
    clearAllTestData()
    sut = nil
    swiftDataManager = nil
  }

  private func createInMemorySwiftDataManager() -> SwiftDataManager {
    // Create a custom SwiftDataManager with in-memory storage
    let manager = SwiftDataManager()
    // Clear any existing data before each test
    manager.deleteAll(ChatSessionModel.self)
    manager.deleteAll(MessageModel.self)
    return manager
  }

  private func clearAllTestData() {
    swiftDataManager?.deleteAll(ChatSessionModel.self)
    swiftDataManager?.deleteAll(MessageModel.self)
  }

  @Test
  func testSaveAndFetchAll() {
    // Given
    let session1 = ChatSessionModel(title: "Session 1")
    let session2 = ChatSessionModel(title: "Session 2")

    // When
    sut.save(session1)
    sut.save(session2)
    let fetchedSessions = sut.fetchAll()

    // Then
    #expect(fetchedSessions.count == 2)
    #expect(fetchedSessions.contains(where: { $0.title == "Session 1" }))
    #expect(fetchedSessions.contains(where: { $0.title == "Session 2" }))
  }

  @Test
  func testFindById() throws {
    // Given
    let sessionId = UUID()
    let session = ChatSessionModel(id: sessionId, title: "Find Me")

    // When
    sut.save(session)
    let foundSession = sut.find(byId: sessionId)

    // Then
    try #require(foundSession != nil)
    #expect(foundSession?.id == sessionId)
    #expect(foundSession?.title == "Find Me")
  }

  @Test
  func testUpdate() {
    // Given
    let session = ChatSessionModel(title: "Original Title")

    // When
    sut.save(session)
    session.title = "Updated Title"
    sut.update(session)
    let fetchedSessions = sut.fetchAll()

    // Then
    #expect(fetchedSessions.count == 1)
    #expect(fetchedSessions.first?.title == "Updated Title")
  }

  @Test
  func testDelete() {
    // Given
    let session = ChatSessionModel(title: "Delete Me")

    // When
    sut.save(session)
    var fetchedSessions = sut.fetchAll()
    #expect(fetchedSessions.count == 1)

    sut.delete(session)
    fetchedSessions = sut.fetchAll()

    // Then
    #expect(fetchedSessions.isEmpty)
  }

  @Test
  func testAddMessage() {
    // Setup: Clear any existing data
    clearAllTestData()

    // Given
    let session = ChatSessionModel(title: "Session with Messages")
    let message = MessageModel(content: "New message", isUserMessage: true)

    // When
    sut.save(session)
    sut.addMessage(message, to: session)
    let fetchedSession = sut.find(byId: session.id)

    // Then
    #expect(fetchedSession?.messages.count == 1)
    #expect(fetchedSession?.messages.first?.content == "New message")
  }
}
