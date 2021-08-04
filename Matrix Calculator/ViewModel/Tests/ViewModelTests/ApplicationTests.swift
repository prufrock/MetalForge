//
// Created by David Kanenwisher on 8/1/21.
//

import XCTest
@testable import ViewModel

final class ApplicationTests: XCTestCase {
    func testMakeApplicationWithResultBuilder() {
        let app = Application(id: UUID()) {
            Button()
        }

        XCTAssertTrue(app.id.uuidString.count > 0)
    }
}
