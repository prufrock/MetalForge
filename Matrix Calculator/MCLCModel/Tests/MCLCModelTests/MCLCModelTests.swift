import XCTest
@testable import MCLCModel

final class MCLCModelTests: XCTestCase {
    func testInitialize() {
        let model = MCLCSingleWindowModel()
        XCTAssertEqual("", model.snapshot().vectorInput)
    }
}
