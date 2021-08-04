//
// Created by David Kanenwisher on 8/1/21.
//

import XCTest
@testable import ViewModel

final class ApplicationTests: XCTestCase {
    func testMakeApplicationWithResultBuilder() {
        let app = Application(id: UUID()) {
            Button(id: UUID(), disabled: true)
        }

        XCTAssertTrue(app.id.uuidString.count > 0)
    }

    func testChangeStateOfButton() {
        var app = Application(id: UUID()) {
            Button(id: UUID(uuidString: "fd61a90a-5982-4393-83fb-5615db9a31f5")!, disabled: true)
        }

        let button = app.getElement(i: 0)
        app = app.setElement(i: 0, element: button.toggle())

        XCTAssertFalse(app.getElement(i: 0).isDisabled())
    }
}
