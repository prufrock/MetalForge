//
// Created by David Kanenwisher on 11/26/21.
//

import Foundation
import XCTest
import simd
@testable import Metal006Buttons


class ColorsETests: XCTestCase {

    func testConvert() {
        let red = ColorsE.red

        XCTAssertEqual(255, red.r())
        XCTAssertEqual(0, red.g())
        XCTAssertEqual(0, red.b())

        let green = ColorsE.green

        XCTAssertEqual(0, green.r())
        XCTAssertEqual(255, green.g())
        XCTAssertEqual(0, green.b())

        let blue = ColorsE.blue

        XCTAssertEqual(0, blue.r())
        XCTAssertEqual(0, blue.g())
        XCTAssertEqual(255, blue.b())
    }
}
