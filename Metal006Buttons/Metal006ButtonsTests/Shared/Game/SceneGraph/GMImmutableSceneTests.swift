//
// Created by David Kanenwisher on 12/3/21.
//

import XCTest
import simd
@testable import Metal006Buttons

class GMImmutableSceneTests: XCTestCase {
    func testClickMiddleButton() {
        let screenDimensions = (Float(414.0), Float(896.0))

        var scene = createScene()
            .setScreenDimensions(width: screenDimensions.0, height: screenDimensions.1)

        var nodes = scene.flatten()

        XCTAssertEqual(15, nodes.count)

        var middleButton = nodes[2]
        XCTAssertEqual(0.0, middleButton.location.rawValue.x)
        XCTAssertEqual(-2.5, middleButton.location.rawValue.y)
        XCTAssertEqual(Float4(.white), middleButton.color)

        scene = scene.click(x: 206.5, y: 823.0)
        nodes = scene.flatten()
        middleButton = nodes[2]
        XCTAssertEqual(Float4(.red), middleButton.color)
    }
}

extension GMImmutableSceneTests {
    func createScene() -> RenderableCollection {
        let root = GMImmutableNode()

        var children: [GMImmutableNode] = []
        (0..<10).forEach { _ in
            children.append(
                GMImmutableNode(
                    children: [],
                    location: Point(
                        Float.random(in: -1...1),
                        Float.random(in: -1...1),
                        Float.random(in: 0...1)
                    ),
                    transformation: matrix_identity_float4x4,
                    vertices: VerticeCollection().c[.cube]!,
                    color: Float4(.green),
                    state: .forward,
                    hidden: false
                )
            )
        }


        return GMImmutableScene(
            node: root.setChildren(children),
            camera: GMImmutableCamera.atOrigin()
        )
    }
}

extension RenderableCollection {
    func flatten() -> [RenderableNode] {
        var nodes: [RenderableNode] = []

        render { node in
            nodes.append(node)
        }

        return nodes
    }
}
