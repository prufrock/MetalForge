//
// Created by David Kanenwisher on 8/1/21.
//

import XCTest
@testable import ViewModel

final class ApplicationTests: XCTestCase {
    func testIDHasAValue() {
        XCTAssertTrue(Application().id.uuidString.count > 0)
    }
}
