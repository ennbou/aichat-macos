import XCTest
@testable import Networking

final class NetworkManagerTests: XCTestCase {
    func testNetworkManager() {
        XCTAssertNotNil(NetworkManager.shared)
    }
}
