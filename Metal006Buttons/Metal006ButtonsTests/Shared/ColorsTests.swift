//
// Created by David Kanenwisher on 11/26/21.
//

import Foundation
import XCTest
import simd
@testable import Metal006Buttons


class ColorsTests: XCTestCase {

    func testConvert() {
        let red = Colors.red

        XCTAssertEqual(255, red.r())
        XCTAssertEqual(0, red.g())
        XCTAssertEqual(0, red.b())

        let green = Colors.green

        XCTAssertEqual(0, green.r())
        XCTAssertEqual(255, green.g())
        XCTAssertEqual(0, green.b())

        let blue = Colors.blue

        XCTAssertEqual(0, blue.r())
        XCTAssertEqual(0, blue.g())
        XCTAssertEqual(255, blue.b())
    }
}
