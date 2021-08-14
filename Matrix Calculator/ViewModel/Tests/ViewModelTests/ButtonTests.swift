import XCTest
@testable import ViewModel

final class ButtonTests: XCTestCase {
    func testDisabled() {
        XCTAssertEqual(VMDLButton(id: UUID(), disabled: true).isDisabled(), true)
    }
}
