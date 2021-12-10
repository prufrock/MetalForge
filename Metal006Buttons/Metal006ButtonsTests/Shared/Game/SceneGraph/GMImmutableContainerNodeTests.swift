//
// Created by David Kanenwisher on 12/10/21.
//

import XCTest
@testable import Metal006Buttons

class GMImmutableContainerNodeTests: XCTestCase {
    func testAddNode() throws {
        let node = basicStringNode("root").add(child: basicStringNode("extra"))

        XCTAssertEqual(1, node.count)
    }

    func testDeleteNode() {
        var rootNode = basicStringNode("root")
        let extraNode = basicStringNode("extra")

        rootNode = rootNode.add(child: extraNode)

        XCTAssertEqual(1, rootNode.count)

        rootNode = rootNode.remove(child: extraNode)

        XCTAssertEqual(0, rootNode.count)

        var carNode = basicStringNode("car")
        var driverNode = basicStringNode("driver")
        var helmetNode = basicStringNode("helmet")

        driverNode = driverNode.add(child: helmetNode)
        carNode = carNode.add(child: driverNode)


        XCTAssertEqual(2, carNode.count)

        carNode = carNode.remove(child: helmetNode)

        XCTAssertEqual(1, carNode.count)
    }
}

// MARK: test helpers
extension GMImmutableContainerNodeTests {
    func basicStringNode(_ element: String) -> GMImmutableContainerNode<String> {
        GMImmutableContainerNode(
            children: [],
            element: element
        )
    }
}
