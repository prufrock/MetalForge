//
// Created by David Kanenwisher on 8/1/21.
//

import XCTest
@testable import ViewModel

final class ApplicationTests: XCTestCase {

    func testCreateApplicationWithUndoButton() {
        let appID = UUID(uuidString: "e3e4d9c2-0a86-4ac1-9847-44d37b67681b")!
        let app = application(id: appID) {
            return $0.undoButton(
                Button(id: UUID(uuidString: "a14fbeec-3c91-4e30-8d25-91b237de41a4")!, disabled: true)
            )
        }.create()

        XCTAssertEqual(appID, app.id)
    }
}
