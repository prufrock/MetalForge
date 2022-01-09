//
// Created by David Kanenwisher on 12/18/21.
//

import simd
import MetalKit

struct TileImage {
    var tiles: [([Float3], Float4x4, Color, MTLPrimitiveType)]
    private let size = Float(1.0)
    private let start = Float(0.0)
    private let tile1: [Float3]

    init(map: Tilemap, wallColor: Color = .white) {
        tile1 = [
            Float3(0.0, 0.0, 0.0),
            Float3(1.0, 1.0, 0.0),
            Float3(0.0, 1.0, 0.0),

            Float3(0.0, 0.0, 0.0),
            Float3(1.0, 0.0, 0.0),
            Float3(1.0, 1.0, 0.0),
        ]

        tiles = [(tile1, matrix_identity_float4x4, .white, .triangle)]

        var myTiles: [([Float3], Float4x4, Color, MTLPrimitiveType)] = []
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                if map[x, y].isWall {
                    myTiles.append((tile1, Float4x4.init(translateX: Float(x), y: Float(y), z: 0), wallColor, .triangle))
                    myTiles.append((tile1, Float4x4.init(translateX: Float(x), y: Float(y), z: 0) * rotateY(.pi/2), .blue, .triangle))
                    myTiles.append((tile1, Float4x4.init(translateX: Float(x) + 1.0, y: Float(y), z: 0) * rotateY(.pi/2), .green, .triangle))
                    myTiles.append((tile1, Float4x4.init(translateX: Float(x), y: Float(y) + 1.0, z: 0) * rotateZ(.pi/2) * rotateY(.pi/2), .red, .triangle))
                    myTiles.append((tile1, Float4x4.init(translateX: Float(x), y: Float(y) - 1.0, z: 0) * rotateZ((3 * .pi)/2) * rotateY(.pi/2), .grey, .triangle))
                    myTiles.append((tile1, Float4x4.init(translateX: Float(x) - 1.0, y: Float(y), z: 0) * rotateZ((2 * .pi)/2) * rotateY(.pi/2), .orange, .triangle))
                }
            }
        }

        tiles = myTiles
    }

    private func rotateY(_ angle: Float) -> Float4x4 {
        Float4x4.identity()
            * Float4x4.init(translateX: Float(0.5), y: Float(0.5), z: 0.5)
            * Float4x4.init(rotateY: angle)
            * Float4x4.init(translateX: -0.5, y: -0.5, z: -0.5)
    }

    private func rotateZ(_ angle: Float) -> Float4x4 {
        Float4x4.identity()
            * Float4x4.init(translateX: 0.5, y: 0.5, z: 0.5)
            * Float4x4.init(rotateZ: angle)
            * Float4x4.init(translateX: -0.5, y: -0.5, z: -0.5)
    }

    private func rotateX(_ angle: Float) -> Float4x4 {
        Float4x4.identity()
            * Float4x4.init(translateX: 0.5, y: 0.5, z: 0.5)
            * Float4x4.init(rotateX: angle)
            * Float4x4.init(translateX: -0.5, y: -0.5, z: -0.5)
    }
}
