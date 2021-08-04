//
// Created by David Kanenwisher on 8/1/21.
//

import XCTest
@testable import ViewModel

final class ApplicationTests: XCTestCase {
    func testIDHasAValue() {
        let app = application(id: UUID()) {
            $0.id = UUID()
            $0.element(Button())
        }.create()
        XCTAssertTrue(app.id.uuidString.count > 0)
    }

    func testMakeApplicationWithResultBuilder() {
        let app = Application(id: UUID()) {
            Button()
        }

        XCTAssertTrue(app.id.uuidString.count > 0)
    }
}
