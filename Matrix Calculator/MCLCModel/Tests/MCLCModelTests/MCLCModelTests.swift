import XCTest
@testable import MCLCModel

final class MCLCModelTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(MCLCSingleWindowModel().text, "Hello, World!")
    }

    func testInitialize() {
        let model = MCLCSingleWindowModel()
        XCTAssertEqual("", model.snapshot().vectorInput)
    }
}
