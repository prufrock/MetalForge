import XCTest
@testable import ViewModel

final class UndoButtonTests: XCTestCase {
    func testDisabled() {
        XCTAssertEqual(UndoButton().isDisabled(), true)
    }
}
