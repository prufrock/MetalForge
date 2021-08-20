//
// Created by David Kanenwisher on 8/1/21.
//

import XCTest
@testable import ViewModel

final class VMDLApplicationTests: XCTestCase {

    func testCreateApplication() {
        let appId = UUID(uuidString: "e3e4d9c2-0a86-4ac1-9847-44d37b67681b")!

        let app = vmdlApplication(id: appId) {
            $0.firstWindow(id: UUID(uuidString: "e3e4d9c2-0a86-4ac1-9847-44d37b67681b")!) {
                $0.undoButton(VMDLButton(id: UUID(uuidString: "a14fbeec-3c91-4e30-8d25-91b237de41a4")!, disabled: true))
                .redoButton(VMDLButton(id: UUID(uuidString: "986b7d3e-3a37-4f4b-9505-da1b8efcf231")!, disabled: true))
                .dotProductButton(VMDLButton(id: UUID(uuidString: "663c9bf7-e004-4de4-8588-283b3f1c3745")!, disabled: true))
            }
        }.create()

        XCTAssertEqual(appId, app.id)
    }
}
