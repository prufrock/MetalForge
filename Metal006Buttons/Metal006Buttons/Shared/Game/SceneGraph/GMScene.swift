//
// Created by David Kanenwisher on 10/24/21.
//

import simd
import MetalKit

func GMCreateScene() -> RenderableCollection {
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
               color: float4(.green),
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