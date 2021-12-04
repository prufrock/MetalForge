//
// Created by David Kanenwisher on 12/3/21.
//

import XCTest
import simd
@testable import Metal006Buttons

class GMImmutableSceneTests {
    func testClickMiddleButton() {
        let scene = createScene()
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
