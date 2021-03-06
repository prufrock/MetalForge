//
// Created by David Kanenwisher on 8/1/21.
//

import XCTest
@testable import ViewModel

final class VMDLMatrixWindowTests: XCTestCase {

    func testCreateWindowWithExpectedId() {
        let windowId = UUID(uuidString: "e3e4d9c2-0a86-4ac1-9847-44d37b67681b")!
        let window = createWindow(id: windowId)

        XCTAssertEqual(windowId, window.id)
        XCTAssertEqual([["0.0", "0.0", "0.0", "0.0"]], window.vector)
    }

    func testChangeStateOfButton() {
        let window = createWindow()

        window.computeDotProduct()
        XCTAssertFalse(window.undoButton.isDisabled())
    }

    func testItsInitializedWithCommandHistory() {
        let window = createWindow(id: nil, commands: ["first command"])

        XCTAssertFalse(window.undoButton.isDisabled())
    }

    private func createWindow(id: UUID? = nil, commands: [String] = []) -> VMDLMatrixWindow {
        let windowId: UUID
        if let id = id {
            windowId = id
        } else {
            windowId = UUID(uuidString: "e3e4d9c2-0a86-4ac1-9847-44d37b67681b")!
        }

        return VMDLMatrixWindow(
                id: windowId,
                undoButton: VMDLButton(id: UUID(uuidString: "a14fbeec-3c91-4e30-8d25-91b237de41a4")!, disabled: true),
                redoButton: VMDLButton(id: UUID(), disabled: false),
                dotProductButton: VMDLButton(id: UUID(uuidString: "663c9bf7-e004-4de4-8588-283b3f1c3745")!, disabled: true),
                commands: commands
        )
    }
}
