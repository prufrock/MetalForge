import XCTest
@testable import ViewModel

final class ButtonTests: XCTestCase {
    func testDisabled() {
        XCTAssertEqual(Button(id: UUID(), disabled: true).isDisabled(), true)
    }
}
