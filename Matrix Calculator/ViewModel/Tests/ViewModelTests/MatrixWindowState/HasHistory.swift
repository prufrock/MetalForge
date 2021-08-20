import XCTest
@testable import ViewModel

final class HasHistoryTests: XCTestCase {
    func testClone() {
        let original = VMDLMatrixWindow.HasHistory(
            id: UUID(),
            undoButton: VMDLButton(id: UUID(), disabled: false),
            dotProductButton: VMDLButton(id: UUID(), disabled: false),
            commands: []
        )

        let cloned = original.clone()

        XCTAssertEqual(cloned.id, original.id)
    }
}
