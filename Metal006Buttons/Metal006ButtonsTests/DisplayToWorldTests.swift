//
// Created by David Kanenwisher on 11/23/21.
//

import XCTest
import simd

class DisplayToWorldTests: XCTestCase {

    func testDisplayToWorld() throws {
        let display: (CGFloat, CGFloat) = (414.0, 896.0)
        let world: (CGFloat, CGFloat) = (1, -1)

        let ratio = displayToWorld(display: display, world: world)

        XCTAssertEqual(world.0, display.0 * ratio.0)
        XCTAssertEqual(world.1, display.1 * ratio.1)
    }

    func displayToWorld(display: (CGFloat, CGFloat), world: (CGFloat, CGFloat)) -> (CGFloat, CGFloat) {
        (world.0 / display.0, world.1 / display.1)
    }
}