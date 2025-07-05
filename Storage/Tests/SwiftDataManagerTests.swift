import XCTest
@testable import Storage
import SwiftData

final class SwiftDataManagerTests: XCTestCase {
    
    var sut: SwiftDataManager!
    
    override func setUp() {
        super.setUp()
        // Setup in-memory configuration for testing
        sut = SwiftDataManager()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testContextCreation() {
        // When
        let mainContext = sut.mainContext
        let newContext = sut.createNewContext()
        
        // Then
        XCTAssertNotNil(mainContext)
        XCTAssertNotNil(newContext)
    }
    
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
        XCTAssertEqual(fetchedSessions.count, 1)
        XCTAssertEqual(fetchedSessions.first?.title, "Test Session")
        XCTAssertEqual(fetchedSessions.first?.messages.count, 1)
        XCTAssertEqual(fetchedSessions.first?.messages.first?.content, "Hello, world!")
    }
    
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
        XCTAssertEqual(fetchedSessions.count, 0)
    }
}
