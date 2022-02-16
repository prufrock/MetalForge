//
// Created by David Kanenwisher on 12/18/21.
//

import simd
import MetalKit

struct TileImage {
    var tiles: [([Float3], [Float2], Float4x4, Color, MTLPrimitiveType, Tile)]
    private let size = Float(1.0)
    private let start = Float(0.0)
    private let tile1: [Float3]
    private let texCoords: [Float2] = [
        Float2(0.2,0.2),
        Float2(0.0,0.0),
        Float2(0.0,0.2),
        Float2(0.2,0.2),
        Float2(0.2,0.0),
        Float2(0.0,0.0)]

    init(map: Tilemap, wallColor: Color = .white) {
        tile1 = [
            Float3(0.0, 0.0, 0.0),
            Float3(1.0, 1.0, 0.0),
            Float3(0.0, 1.0, 0.0),

            Float3(0.0, 0.0, 0.0),
            Float3(1.0, 0.0, 0.0),
            Float3(1.0, 1.0, 0.0),
        ]

        tiles = [(tile1, texCoords, matrix_identity_float4x4, .white, .triangle, .floor)]

        var myTiles: [([Float3], [Float2], Float4x4, Color, MTLPrimitiveType, Tile)] = []
        for y in 0 ..< map.height {
            for x in 0 ..< map.width {
                if map[x, y].isWall {
                    myTiles.append((tile1, texCoords, Float4x4.init(translateX: Float(x), y: Float(y), z: 0), wallColor, .triangle, map[x, y]))
                    myTiles.append((tile1, texCoords, Float4x4.init(translateX: Float(x) + 1.0, y: Float(y), z: 0) * rotateY(.pi/2), .green, .triangle, map[x, y]))
                    myTiles.append((tile1, texCoords, Float4x4.init(translateX: Float(x), y: Float(y) + 1.0, z: 0) * rotateZ(.pi/2) * rotateY(.pi/2), .red, .triangle, map[x, y]))
                    myTiles.append((tile1, texCoords, Float4x4.init(translateX: Float(x), y: Float(y) - 1.0, z: 0) * rotateZ((3 * .pi)/2) * rotateY(.pi/2), .grey, .triangle, map[x, y]))
                    myTiles.append((tile1, texCoords, Float4x4.init(translateX: Float(x) - 1.0, y: Float(y), z: 0) * rotateZ((2 * .pi)/2) * rotateY(.pi/2), .orange, .triangle, map[x, y]))
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
