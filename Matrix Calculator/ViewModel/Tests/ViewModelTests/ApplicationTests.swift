//
// Created by David Kanenwisher on 8/1/21.
//

import XCTest
@testable import ViewModel

final class ApplicationTests: XCTestCase {
    func testIDHasAValue() {
        let app = application(UUID()) {
            $0.id = UUID()
        }.create()
        XCTAssertTrue(app.id.uuidString.count > 0)
    }
}
