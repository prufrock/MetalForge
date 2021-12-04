//
// Created by David Kanenwisher on 11/23/21.
//

import XCTest
import simd
@testable import Metal006Buttons


class DisplayToNdcTests: XCTestCase {

    func testDisplayToNdc() throws {
        let display: Float2 = Float2(414.0, 896.0)
        let world: Float2 = Float2(1, -1)

        var coords: Float2 = display.displayToNdc(display: display)

        XCTAssertEqual(world[0], coords[0])
        XCTAssertEqual(world[1], coords[1])

        coords = Float2(display.x / 2, display.y / 2).displayToNdc(display: display)

        XCTAssertEqual(0, coords[0])
        XCTAssertEqual(0, coords[1])
    }

    func testDisplayToNdc4x4() throws {
        let display: Float2 = Float2(414.0, 896.0)
        let world: Float2 = Float2(1, -1)

        var coords: float4x4 = display.displayToNdc(display: display)

        XCTAssertEqual(world[0], coords[0][0])
        XCTAssertEqual(world[1], coords[1][1])

        coords = Float2(display.x / 2, display.y / 2).displayToNdc(display: display)

        XCTAssertEqual(0, coords[0][0])
        XCTAssertEqual(0, coords[1][1])
    }
}