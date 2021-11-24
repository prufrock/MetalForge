//
// Created by David Kanenwisher on 11/23/21.
//

import XCTest
import simd
@testable import Metal006Buttons


class DisplayToWorldTests: XCTestCase {

    func testDisplayToWorld() throws {
        let display: SIMD2<Float> = SIMD2<Float>(414.0, 896.0)
        let world: SIMD2<Float> = SIMD2<Float>(1, -1)

        let result = display.displayToWorld(display: display, world: world)

        XCTAssertEqual(world[0], result[0])
        XCTAssertEqual(world[1], result[1])
    }

    func displayToWorld(display: SIMD2<Float>, world: SIMD2<Float>) -> SIMD2<Float> {
        SIMD2<Float>(world[0] / display[0], world[1] / display[1])
    }
}