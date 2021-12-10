//
// Created by David Kanenwisher on 12/10/21.
//

import XCTest
@testable import Metal006Buttons

class GMImmutableContainerNodeTests: XCTestCase {
    func testAddNode() throws {
        let node = basicStringNode().add(child: basicStringNode())

        XCTAssertEqual(1, node.children.count)
    }
}

// MARK: test helpers
extension GMImmutableContainerNodeTests {
    func basicStringNode() -> GMImmutableContainerNode<String> {
        GMImmutableContainerNode(
            children: [],
            location: Point.origin(),
            transformation: Float4x4.identity(),
            vertices: Vertices(),
            color: Float4(Colors.blue),
            hidden: true,
            item: "a thing"
        )
    }
}
