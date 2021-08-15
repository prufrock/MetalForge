//
// Created by David Kanenwisher on 8/1/21.
//

import XCTest
@testable import ViewModel

final class ApplicationTests: XCTestCase {

    func testCreateApplicationWithUndoButton() {
        let windowID = UUID(uuidString: "e3e4d9c2-0a86-4ac1-9847-44d37b67681b")!
        var app = application(id: windowID) {
            $0.undoButton(
                VMDLButton(id: UUID(uuidString: "a14fbeec-3c91-4e30-8d25-91b237de41a4")!, disabled: true)
            ).dotProductButton(
                VMDLButton(id: UUID(uuidString: "663c9bf7-e004-4de4-8588-283b3f1c3745")!, disabled: true)
            )
        }.create()

        XCTAssertEqual(windowID, app.id)
    }

    func testChangeStateOfButton() {
        var app = application(id: UUID(uuidString: "e3e4d9c2-0a86-4ac1-9847-44d37b67681b")!) {
            $0.undoButton(
                VMDLButton(id: UUID(uuidString: "a14fbeec-3c91-4e30-8d25-91b237de41a4")!, disabled: true)
            ).dotProductButton(
                VMDLButton(id: UUID(uuidString: "70415f15-ce34-4cce-8200-8d7647e2ec71")!, disabled: true)
            )
        }.create()

        app.computeDotProduct()
        XCTAssertFalse(app.getUndoButton().isDisabled())
    }
}
