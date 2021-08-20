import XCTest
@testable import ViewModel

final class NoHistoryTests: XCTestCase {
    func testClone() {
        let original = VMDLMatrixWindow.NoHistory(
            id: UUID(),
            undoButton: VMDLButton(id: UUID(), disabled: false),
            dotProductButton: VMDLButton(id: UUID(), disabled: false),
            commands: []
        )

        let cloned = original.clone()

        XCTAssertEqual(cloned.id, original.id)
    }
}
