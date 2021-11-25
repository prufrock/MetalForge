//
// Created by David Kanenwisher on 11/23/21.
//

import XCTest
import simd
@testable import Metal006Buttons


class DisplayToNdcTests: XCTestCase {

    func testDisplayToNdc() throws {
        let display: SIMD2<Float> = SIMD2<Float>(414.0, 896.0)
        let world: SIMD2<Float> = SIMD2<Float>(1, -1)

        let result = display.displayToNdc(display: display)

        XCTAssertEqual(world[0], result[0])
        XCTAssertEqual(world[1], result[1])

        var coords = SIMD2<Float>(display.x / 2, display.y / 2).displayToNdc(display: display)

        XCTAssertEqual(0, coords[0])
        XCTAssertEqual(0, coords[1])
    }
}