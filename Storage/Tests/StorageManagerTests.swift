import XCTest
@testable import Storage

final class StorageManagerTests: XCTestCase {
    
    var sut: StorageManager!
    var fileManager: FileManager!
    
    override func setUp() {
        super.setUp()
        fileManager = FileManager.default
        sut = StorageManager(fileManager: fileManager)
    }
    
    override func tearDown() {
        sut = nil
        fileManager = nil
        super.tearDown()
    }
    
    func testSaveAndRetrieve() throws {
        // Given
        let testString = "Test string to save"
        let key = "testKey"
        
        // When
        try sut.save(testString, forKey: key)
        let retrievedString = try sut.retrieve(forKey: key, as: String.self)
        
        // Then
        XCTAssertEqual(testString, retrievedString)
    }
    
    func testDelete() throws {
        // Given
        let testString = "Test string to delete"
        let key = "testDeleteKey"
        
        // When
        try sut.save(testString, forKey: key)
        XCTAssertTrue(sut.exists(forKey: key))
        
        // Then
        try sut.delete(forKey: key)
        XCTAssertFalse(sut.exists(forKey: key))
    }
    
    func testExists() throws {
        // Given
        let testString = "Test string to check existence"
        let key = "testExistsKey"
        
        // When
        XCTAssertFalse(sut.exists(forKey: key))
        try sut.save(testString, forKey: key)
        
        // Then
        XCTAssertTrue(sut.exists(forKey: key))
    }
}
