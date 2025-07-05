import XCTest
@testable import Storage
import SwiftData

final class ChatSessionRepositoryTests: XCTestCase {
    
    var sut: ChatSessionRepository!
    var swiftDataManager: SwiftDataManager!
    
    override func setUp() {
        super.setUp()
        swiftDataManager = SwiftDataManager()
        sut = ChatSessionRepository(swiftDataManager: swiftDataManager)
    }
    
    override func tearDown() {
        sut = nil
        swiftDataManager = nil
        super.tearDown()
    }
    
    func testSaveAndFetchAll() {
        // Given
        let session1 = ChatSessionModel(title: "Session 1")
        let session2 = ChatSessionModel(title: "Session 2")
        
        // When
        sut.save(session1)
        sut.save(session2)
        let fetchedSessions = sut.fetchAll()
        
        // Then
        XCTAssertEqual(fetchedSessions.count, 2)
        XCTAssertTrue(fetchedSessions.contains(where: { $0.title == "Session 1" }))
        XCTAssertTrue(fetchedSessions.contains(where: { $0.title == "Session 2" }))
    }
    
    func testFindById() {
        // Given
        let sessionId = UUID()
        let session = ChatSessionModel(id: sessionId, title: "Find Me")
        
        // When
        sut.save(session)
        let foundSession = sut.find(byId: sessionId)
        
        // Then
        XCTAssertNotNil(foundSession)
        XCTAssertEqual(foundSession?.id, sessionId)
        XCTAssertEqual(foundSession?.title, "Find Me")
    }
    
    func testUpdate() {
        // Given
        let session = ChatSessionModel(title: "Original Title")
        
        // When
        sut.save(session)
        session.title = "Updated Title"
        sut.update(session)
        let fetchedSessions = sut.fetchAll()
        
        // Then
        XCTAssertEqual(fetchedSessions.count, 1)
        XCTAssertEqual(fetchedSessions.first?.title, "Updated Title")
    }
    
    func testDelete() {
        // Given
        let session = ChatSessionModel(title: "Delete Me")
        
        // When
        sut.save(session)
        var fetchedSessions = sut.fetchAll()
        XCTAssertEqual(fetchedSessions.count, 1)
        
        sut.delete(session)
        fetchedSessions = sut.fetchAll()
        
        // Then
        XCTAssertEqual(fetchedSessions.count, 0)
    }
    
    func testAddMessage() {
        // Given
        let session = ChatSessionModel(title: "Session with Messages")
        let message = MessageModel(content: "New message", isUserMessage: true)
        
        // When
        sut.save(session)
        sut.addMessage(message, to: session)
        let fetchedSession = sut.find(byId: session.id)
        
        // Then
        XCTAssertEqual(fetchedSession?.messages.count, 1)
        XCTAssertEqual(fetchedSession?.messages.first?.content, "New message")
    }
}
